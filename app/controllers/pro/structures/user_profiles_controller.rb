# encoding: utf-8
class Pro::Structures::UserProfilesController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def index
    search_params = params
    search_params[:structure_id] = @structure.id
    @user_profiles = UserProfileSearch.search(params).results

    respond_to do |format|
        format.json { render json: @structure.user_profiles }
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

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
