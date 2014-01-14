# encoding: utf-8
class Pro::CitySubjectInfosController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def new
    @city       = City.find params[:city_id]
    @subject    = Subject.find params[:subject_id]
    _city_id    = @city.id
    _subject_id = @subject.id
    if (@city_subject_info = CitySubjectInfo.where{(city_id == _city_id) & (subject_id == _subject_id)}.first).nil?
      @city_subject_info = CitySubjectInfo.new(city_id: @city.id, subject_id: @subject.id)
    end
  end


  def create
    @city      = City.find params[:city_subject_info][:city_id]
    @subject   = Subject.find params[:city_subject_info][:subject_id]
    city_id    = @city.id
    subject_id = @subject.id
    if (@city_subject_info = CitySubjectInfo.where{(city_id == city_id) & (subject_id == subject_id)}.first).nil?
      @city_subject_info = CitySubjectInfo.new(city_id: @city.id, subject_id: @subject.id)
    end
    @city_subject_info.update_attributes params[:city_subject_info]
    redirect_to pro_subjects_path
  end

end
