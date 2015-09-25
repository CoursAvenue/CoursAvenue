# encoding: utf-8
class Pro::CitySubjectInfosController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def new
    @city       = City.find params[:city_id]
    @subject    = Subject.fetch_by_id_or_slug params[:subject_id]
    _city_id    = @city.id
    _subject_id = @subject.id
    if (@city_subject_info = CitySubjectInfo.where( CitySubjectInfo.arel_table[:city_id].eq(_city_id).and(
                                                    CitySubjectInfo.arel_table[:subject_id].eq(_subject_id)) ).first).nil?
      @city_subject_info = CitySubjectInfo.new(city_id: @city.id, subject_id: @subject.id)
    end
  end

  def create
    @city       = City.find params[:city_subject_info][:city_id]
    @subject    = Subject.fetch_by_id_or_slug params[:city_subject_info][:subject_id]
    _city_id    = @city.id
    _subject_id = @subject.id
    if (@city_subject_info = CitySubjectInfo.where( CitySubjectInfo.arel_table[:city_id].eq(_city_id).and(
                                                    CitySubjectInfo.arel_table[:subject_id].eq(_subject_id)) ).first).nil?
      @city_subject_info = CitySubjectInfo.new(city_id: @city.id, subject_id: @subject.id)
    end
    @city_subject_info.update_attributes params[:city_subject_info]
    respond_to do |format|
      format.js { render nothing: true }
      format.html { redirect_to admin_subjects_path }
    end
  end
end
