# encoding: utf-8
class PlanningsController < ApplicationController

  layout 'home'

  def index
    @city = City.find(params[:city_id]) rescue City.find('paris')
    if params[:subject_id].present? or params[:root_subject_id].present?
      @subject      = Subject.find(params[:subject_id] || params[:root_subject_id])
      @root_subject = @subject.root
    end
  end
end
