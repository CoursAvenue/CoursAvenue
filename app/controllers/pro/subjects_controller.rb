# encoding: utf-8
class Pro::SubjectsController < Pro::ProController
  include SubjectSeeker

  before_action :authenticate_pro_super_admin!, except: :descendants

  def index
    @city = City.find 'paris'
    @structure_search = StructureSearch.search( { lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true })
  end

  def all
    @roots    = Subject.roots.order('name ASC').all
    @parents  = Subject.at_depth(1).order('name ASC').all
    @children = Subject.at_depth(2).order('name ASC').all
    @subjects = @roots + @parents + @children
  end

  def new
    @parent  = Subject.find params[:parent_id]
    @subject = @parent.children.build
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def create
    @subject = Subject.create params[:subject]
    respond_to do |format|
      format.html { redirect_to all_pro_subjects_path }
    end
  end

  def edit_name
    @subject    = Subject.friendly.find params[:id]
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def edit
    @subject    = Subject.friendly.find params[:id]
    @city       = City.find('paris')
    _city_id    = @city.id
    _subject_id = @subject.id
    if (@city_subject_info = CitySubjectInfo.where { (city_id == _city_id) & (subject_id == _subject_id) }.first).nil?
      @city_subject_info = CitySubjectInfo.new(city_id: @city.id, subject_id: @subject.id)
    end
  end

  def update
    @subject = Subject.friendly.find params[:id]
    respond_to do |format|
      if @subject.update_attributes params[:subject]
        format.js { render nothing: true }
        format.html { redirect_to pro_subjects_path }
      else
        format.html { render action: :edit }
      end
    end
  end

  # Params:
  #    ids: subject ids separeted by comas (123,124,53)
  #  Returns json:
  #     Danse - Danse de salon :
  #           - Salsa
  #           - Zumba
  #           - ...
  #     Cuisine - ...:
  #           - ...
  def descendants
    @descendants = get_descendants params
    respond_to do |format|
      if params[:callback]
        format.js { render json: { descendants: @descendants.to_json }, callback: params[:callback] }
      else
        format.json { render json: @descendants.to_json }
      end
    end
  end
end
