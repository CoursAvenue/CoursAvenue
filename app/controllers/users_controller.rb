# encoding: utf-8
class UsersController < InheritedResources::Base

  layout :get_layout

  actions :show, :update

  load_and_authorize_resource :user, find_by: :slug, except: [:first_update, :unsubscribe, :waiting_for_activation]

  def waiting_for_activation
  end

  def show
    @user = User.find(params[:id])
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

  def dashboard
    @user               = User.find(params[:id])
    @profile_completion = current_user.profile_completion
    @conversations      = current_user.mailbox.conversations.limit(4)
    if @user.city
      @structure_search = StructureSearch.search({lat: @user.city.latitude,
                                                  lng: @user.city.longitude,
                                                  radius: 7,
                                                  per_page: 150,
                                                  bbox: true,
                                                  subject_slugs: (@user.passions.any? ? @user.passions.map(&:subject).compact.map(&:slug) : [])
                                                  }).results

      @structure_locations = Gmaps4rails.build_markers(@structure_search) do |structure, marker|
        marker.lat structure.latitude
        marker.lng structure.longitude
      end
    else
      @structure_locations = Gmaps4rails.build_markers(City.where{zip_code == '75000'}.first) do |city, marker|
        marker.lat city.latitude
        marker.lng city.longitude
      end
    end
  end

  def update
    update! do |format|
      format.html { redirect_to (params[:return_to] || edit_user_path(current_user)), notice: 'Votre profil a bien été mis à jour.' }
    end
  end

  def first_update
    @user = User.find(params[:id])
    if @user.reset_password_token_valid?(params[:reset_password_token]) and params[:user][:password].present?
      conversation = @user.mailbox.conversations.last
      @user.update_attributes(params[:user])
      @user.reply_to_conversation(conversation, params[:message])
      sign_in @user, :bypass => true
      redirect_to user_conversation_path(current_user, conversation), notice: 'Vous êtes maintenant connecté.'
    else
      redirect_to root_path, alert: "Vous n'avez pas la permission"
    end
  end

  private

  def get_layout
    if action_name == 'waiting_for_activation'
      'empty'
    else
      'user_profile'
    end
  end

end
