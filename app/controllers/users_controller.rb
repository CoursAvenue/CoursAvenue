# encoding: utf-8
class UsersController < InheritedResources::Base
  layout :get_layout

  actions :show, :update

  before_action :authenticate_user!, except: [:unsubscribe, :waiting_for_activation, :invite_entourage_to_jpo_page, :invite_entourage_to_jpo, :welcome]
  load_and_authorize_resource :user, find_by: :slug, except: [:unsubscribe, :waiting_for_activation, :invite_entourage_to_jpo_page, :invite_entourage_to_jpo, :welcome]

  # params[:structure] : structure_slug
  # method: GET
  def invite_entourage_to_jpo_page
    if params[:id]
      @user = User.find params[:id]
    elsif current_user
      @user = current_user
    elsif params[:user_email].present?
      @user = User.where(email: params[:user_email]).first_or_initialize
      @user.save(validate: false)
    end
    @structure = Structure.find(params[:structure_id]) if params[:structure_id].present?
    respond_to do |format|
      if @user.nil?
        format.html { redirect_to open_courses_path }
      else
        format.html
      end
    end
  end

  def waiting_for_activation
  end

  def show
    @user = User.find(params[:id])
  end

  def edit_private_infos
    @user = User.find(params[:id])
  end

  # PATCH
  def update_password
    @user = User.find(current_user.id)
    if @user.update(params[:user])
      # Sign in the user by passing validation in case his password changed
      sign_in @user, bypass: true
      redirect_to edit_private_info_user_path(@user), notice: 'Votre mot de passe a bien été mis à jour'
    else
      render action: :edit_private_infos
    end
  end

  def notifications
  end

  def unsubscribe
    if user = User.read_access_token(params[:signature])
      user.update_attribute :email_opt_in, false
      redirect_to root_url, notice: 'Vous avez bien été desinscrit de la liste.'
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
    @user               = User.find(params[:id])
    @wizard             = get_next_wizard
    @profile_completion = @user.profile_completion
    @conversations      = @user.mailbox.conversations.limit(4)
    if @user.city
      @structure_search = StructureSearch.search({ lat: @user.city.latitude,
                                                   lng: @user.city.longitude,
                                                   radius: 7,
                                                   per_page: 150,
                                                   bbox: true,
                                                   subject_slugs: (@user.passions.any? ? @user.passions.map(&:subjects).flatten.compact.map(&:slug) : []) }).results

      @structure_locations = Gmaps4rails.build_markers(@structure_search) do |structure, marker|
        marker.lat structure.latitude
        marker.lng structure.longitude
      end
    else
      @structure_locations = Gmaps4rails.build_markers(City.where { zip_code == '75000' }.first) do |city, marker|
        marker.lat city.latitude
        marker.lng city.longitude
      end
    end
  end

  def update_passions
    @user = User.find params[:id]
    merge_passions_subject_descendants_ids
    params[:user][:passions_attributes].each do |index, passions_attribute|
      if passions_attribute[:id].present?
        passion = @user.passions.find(passions_attribute[:id])
        passion.update_attributes(passions_attribute)
      else
        @user.passions.create passions_attribute
      end
    end
    @user.save
    respond_to do |format|
      format.html { redirect_to user_passions_path(@user), notice: 'Vos passions ont bien été mises à jour.' }
    end
  end

  def update
    update! do |format|
      format.html { redirect_to (params[:return_to] || edit_user_path(@user)), notice: 'Votre profil a bien été mis à jour.' }
    end
  end

  private

  def get_layout
    if action_name == 'waiting_for_activation' or action_name == 'invite_entourage_to_jpo_page' or action_name == 'welcome'
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
        unless wizard.completed?.call(current_user)
          session[:current_wizard_id] = wizard.id
          return wizard
        end
      end
      return nil
    end
  end

  private

  # Merge subject_descendants_ids into subject_ids
  # Turns: {
  #   subject_ids              => [12]
  #   subject_descendants_ids  => [231]
  # }
  # Into: {
  #   subject_ids              => [12, 231]
  #   subject_descendants_ids  => [231]
  # }
  #
  # @return nil
  def merge_passions_subject_descendants_ids
    if params[:user].has_key? :passions_attributes
      params[:user][:passions_attributes].each do |index, passions_attributes|
        passions_attributes[:subject_ids] = passions_attributes[:subject_ids] + passions_attributes[:subject_descendants_ids] if passions_attributes[:subject_descendants_ids]
      end
    end
  end
end
