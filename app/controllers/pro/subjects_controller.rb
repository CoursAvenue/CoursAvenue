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

  def completion
    subject   = Subject.fetch_by_id_or_slug params[:id]
    zippy     = (params[:zip_code].present? ? params[:zip_code] : '75000')
    zip_codes = City.where( City.arel_table[:zip_code].matches("#{zippy}%") ).map(&:zip_code).reject{|zip| zip.include?('CEDEX')}.uniq
    respond_to do |format|
      format.json do
        render json: {
          0 => StructureSearch.search(email_status: ['no_logo_yet', 'incomplete_profile', 'no_recommendations'], zip_codes: zip_codes, subject_ids: [subject.id]).total,
          1 => StructureSearch.search(email_status: ['less_than_five_recommendations'], zip_codes: zip_codes, subject_ids: [subject.id]).total,
          2 => StructureSearch.search(email_status: ['less_than_fifteen_recommendations', 'planning_outdated', 'more_than_fifteen_recommendations'], zip_codes: zip_codes, subject_ids: [subject.id]).total
        }
      end
    end
  end

  def new
    @parent  = Subject.fetch_by_id_or_slug params[:parent_id]
    @subject = @parent.children.build
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def create
    @subject = Subject.create params[:subject]
    Rails.cache.delete "Pro::SubjectsController#descendants::#{@subject.parent.try(:id)}"
    Rails.cache.delete "Pro::SubjectsController#descendants::#{@subject.root.id}"
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
    if (@city_subject_info = CitySubjectInfo.where(CitySubjectInfo.arel_table[:city_id].eq(_city_id).and(
                                                   CitySubjectInfo.arel_table[:subject_id].eq(_subject_id))).first).nil?
      @city_subject_info = CitySubjectInfo.new(city_id: @city.id, subject_id: @subject.id)
    end
  end

  def update
    @subject = Subject.friendly.find params[:id]
    respond_to do |format|
      if @subject.update_attributes params[:subject]
        format.js { render nothing: true }
        format.html { redirect_to all_pro_subjects_path }
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
    @descendants = Rails.cache.fetch "Pro::SubjectsController#descendants::#{params[:ids]}" do
       get_descendants(params).to_json
    end
    respond_to do |format|
      if params[:callback]
        format.js { render json: { descendants: @descendants }, callback: params[:callback] }
      else
        format.json { render json: @descendants }
      end
    end
  end
end
