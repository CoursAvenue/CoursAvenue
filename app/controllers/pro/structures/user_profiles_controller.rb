# encoding: utf-8
class Pro::Structures::UserProfilesController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def index
    @user_profiles = UserProfileSearch.search(params)
  end

  def new
    @user_profile = @structure.user_profiles.build
  end

  def create
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
