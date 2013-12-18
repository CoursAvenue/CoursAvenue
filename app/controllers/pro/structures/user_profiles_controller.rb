# encoding: utf-8
class Pro::Structures::UserProfilesController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def index
    search_params = params
    search_params[:structure_id] = @structure.id
    @user_profiles_search = UserProfileSearch.search(params)
    @user_profiles = @user_profiles_search.results

    respond_to do |format|
      format.json { render json: @user_profiles, root: 'user_profiles', meta: { total: @user_profiles_search.total }}
      format.html
    end
  end

  def new
    @user_profile = @structure.user_profiles.build
  end

  def create
    @user_profile = @structure.user_profiles.build params[:user_profile]

    respond_to do |format|
      if @user_profile.save
        format.html { redirect_to pro_structure_user_profiles_path(@structure) }
      else
        format.html { render :new }
      end
    end
  end

  def update
    @user_profile = @structure.user_profiles.find params[:id]

    tags = params[:user_profile].delete(:tags)
    @structure.tag(@user_profile, with: tags, on: :tags)

    respond_to do |format|
      if @user_profile.update_attributes(params[:user_profile])
        format.json { render nothing: true, status: 200 }
      else
        format.json { render nothing: true, status: 500 }
      end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
