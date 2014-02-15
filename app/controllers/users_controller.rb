# encoding: utf-8
class UsersController < InheritedResources::Base
  layout :get_layout

  actions :show, :update

  load_and_authorize_resource :user, find_by: :slug, except: [:unsubscribe, :waiting_for_activation, :invite_entourage_to_jpo_page, :invite_entourage_to_jpo]

  # params[:structure] : structure_slug
  # method: GET
  def invite_entourage_to_jpo_page
    if current_user
      @user = current_user
    else
      @user = User.where(email: params[:user_email]).first_or_initialize
      @user.save(validate: false)
    end
    @structure = Structure.find(params[:structure_id]) if params[:structure_id].present?
  end

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
      @structure_search = StructureSearch.search({ lat: @user.city.latitude,
                                                   lng: @user.city.longitude,
                                                   radius: 7,
                                                   per_page: 150,
                                                   bbox: true,
                                                   subject_slugs: (@user.passions.any? ? @user.passions.map(&:subject).compact.map(&:slug) : []) }).results

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

  def update
    update! do |format|
      format.html { redirect_to (params[:return_to] || edit_user_path(current_user)), notice: 'Votre profil a bien été mis à jour.' }
    end
  end

  private

  def get_layout
    if action_name == 'waiting_for_activation' or action_name == 'invite_entourage_to_jpo_page'
      'empty'
    else
      'user_profile'
    end
  end
end
