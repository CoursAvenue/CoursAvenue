# encoding: utf-8
class Pro::Structures::BulkUserProfilesController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def create
    tags = params.delete(:tags)
    @user_profiles = UserProfile.where(id: params[:ids]).find_each do |profile|
      @structure.tag(profile, with: tags, on: :tags)
    end

    # TODO not sure what to do here
    # check if the tagging worked?
    respond_to do |format|
      if true
        format.json { render :nothing => true }
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
