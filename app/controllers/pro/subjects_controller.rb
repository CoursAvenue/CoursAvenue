# encoding: utf-8
class Pro::SubjectsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @city = City.find 'paris'
    @structure_search            = StructureSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true})
  end

  def edit
    @subject = Subject.friendly.find params[:id]
  end

  def update
    @subject = Subject.friendly.find params[:id]
    respond_to do |format|
      if @subject.update_attributes params[:subject]
        format.html { redirect_to pro_subjects_path}
      else
        format.html { render action: :edit }
      end
    end
  end

end
