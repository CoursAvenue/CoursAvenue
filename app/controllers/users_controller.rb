# encoding: utf-8
class UsersController < InheritedResources::Base
  layout :get_layout

  actions :show, :update

  before_action :authenticate_user!, except: [:unsubscribe, :waiting_for_activation,
                                              :welcome, :create, :facebook_auth_callback,
                                              :edit_private_infos, :facebook_auth_failure]

  load_and_authorize_resource :user, find_by: :slug, except: [:unsubscribe, :waiting_for_activation,
                                                              :welcome, :create, :facebook_auth_callback,
                                                              :edit_private_infos, :facebook_auth_failure]

  # Create from newsletter
  # GET /users
  def create
    user = User.force_create(email: params[:user][:email], zip_code: params[:user][:zip_code], sign_up_at: Time.now, subscription_from: params[:user][:subscription_from])
    UserMailer.delay(queue: 'mailers').subscribed_to_newsletter(user) if params[:user][:subscription_from] == 'newsletter' and user.persisted?
    respond_to do |format|
      format.js
      format.html { redirect_to params[:redirect_to] || root_path }
    end
  end

  def waiting_for_activation
  end

  def show
    @user = User.find(params[:id])
    redirect_to edit_user_path(@user)
  end

  def edit_private_infos
    @user = User.find(params[:id])
  end

  # PATCH
  def update_password
    @user = User.find(current_user.id)
    new_params = user_params
    if new_params[:password].blank?
      new_params.delete(:password)
      new_params.delete(:password_confirmation)
    end
    if @user.update(new_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, bypass: true
      redirect_to edit_private_infos_user_path(@user), notice: 'Votre mot de passe a bien été mis à jour'
    else
      render action: :edit_private_infos
    end
  end

  def unsubscribe
    if user = User.read_access_token(params[:signature])
      user.update_attribute :email_opt_in, false
      user.update_attribute :email_promo_opt_in, false
      user.update_attribute :email_newsletter_opt_in, false
      user.update_attribute :community_notification_opt_in, false
      redirect_to unsubscribed_users_url
    else
      redirect_to root_url, notice: 'Lien invalide.'
    end
  end

  # GET
  # Returns the next wizard given
  def wizard
    @wizard = get_next_wizard
    respond_to do |format|
      if @wizard
        format.json { render json: { form: render_to_string(partial: @wizard.partial, layout: false, formats: [:html]), done: false }  }
      else
        format.json { render json: { done: true }  }
      end
    end
  end

  # GET
  # Dashboard of the user
  def dashboard
    @user                   = User.find(params[:id])
    @wizard                 = get_next_wizard
    @profile_completion     = @user.profile_completion
    @participation_requests = (@user.participation_requests.upcoming.accepted + @user.participation_requests.upcoming.pending).sort_by(&:date)
    @conversations          = (@user.mailbox.conversations - @participation_requests.map(&:conversation))[0..4]
  end

  def update
    if params[:user] && params[:user][:subject_descendants_ids].present?
      params[:user][:subject_ids] = params[:user][:subject_ids] + params[:user].delete(:subject_descendants_ids)
    end
    @user.subjects = Subject.find(params[:user][:subject_ids].reject(&:blank?)) if params[:user][:subject_ids]
    update! do |format|
      format.html { redirect_to (params[:return_to] || edit_user_path(@user)), notice: 'Votre profil a bien été mis à jour.' }
      format.js   { render nothing: true }
    end
  end

  def destroy_confirmation
    render layout: false
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_path(notice: 'Vous allez nous manquer...') }
    end
  end

  def facebook_auth_callback
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Facebook'

      # Update oauth token and expires at
      auth = request.env['omniauth.auth']
      @user.oauth_token        = auth.credentials.token
      @user.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      sign_in(Devise::Mapping.find_scope!(@user), @user, event: :authentication)

      redirect_url = after_omni_auth_sign_in_path_for(@user)
      respond_to do |format|
        format.html { redirect_to redirect_url }
        format.json { render json: UserSerializer.new(@user).to_json }
      end
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']

      respond_to do |format|
        format.html { redirect_to redirect_url }
        format.json { render json: { redirect_url: root_path(anchor: 'connexion') } }
      end
    end
  end

  def facebook_auth_failure
    redirect_to new_user_session_path, flash: { error: I18n.t('devise.omniauth_callbacks.failure', kind: 'Facebook') }
  end

  private

  def get_layout
    if action_name == 'waiting_for_activation' or action_name == 'welcome'
      'empty'
    else
      'user_profile'
    end
  end

  # Return the next wizard regarding the params passed (skip: true)
  # and wizards that are completed
  #
  # @return Wizard
  def get_next_wizard
    # Return nil if there is no next wizard
    if params[:next] && session[:current_wizard_id] && session[:current_wizard_id] == User::Wizard.data.length
      return nil
    # Return the next wizard if it's not completed, else, it increments
    elsif params[:next] && session[:current_wizard_id] && session[:current_wizard_id] < User::Wizard.data.length
      session[:current_wizard_id] += 1
      wizard = User::Wizard.find(session[:current_wizard_id])
      if wizard.completed?.call(current_user)
        return get_next_wizard
      else
        return wizard
      end
    else
      User::Wizard.all.each do |wizard|
        unless wizard.completed?.call(@user)
          session[:current_wizard_id] = wizard.id
          return wizard
        end
      end
      return nil
    end
  end

  def after_omni_auth_sign_in_path_for(user)
    session[:after_sign_up_url] = user.after_sign_up_url || session['user_return_to'] || dashboard_user_path(user)
    if user.sign_in_count == 1
      welcome_users_path
    else
      session[:after_sign_up_url]
    end
  end

  def user_params
    params.require(:user).permit(:id, :first_name, :last_name, :gender, :description,
                                 :birthdate, :phone_number, :zip_code, :city_id, :remote_avatar_url,
                                 :password, :password_confirmation, :current_password,
                                 :email_promo_opt_in, :email_newsletter_opt_in,
                                 :sms_opt_in, :community_notification_opt_in)
  end
end
