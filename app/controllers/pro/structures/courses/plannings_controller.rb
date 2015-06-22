# encoding: utf-8
class Pro::Structures::Courses::PlanningsController < InheritedResources::Base
  layout 'admin'

  before_action :authenticate_pro_admin!
  before_action :load_structure
  before_action :retrieve_places

  belongs_to :course
  load_and_authorize_resource :structure, find_by: :slug

  def new
    @course   = Course.friendly.find(params[:course_id])
    @planning = @course.plannings.build
    respond_to do |format|
      if request.xhr?
        format.html { render partial: "pro/structures/courses/plannings/form" }
      else
        format.html do
          render template: 'pro/structures/courses/plannings/index'
        end
      end
    end
  end

  def edit
    @planning  = Planning.find(params[:id])
    respond_to do |format|
      if request.xhr?
        format.html { render partial: "pro/structures/courses/plannings/form" }
      end
    end
  end

  def create
    @planning           = Planning.new(params[:planning])
    @planning.course    = @course
    set_dates_and_times
    respond_to do |format|
      if @planning.save
        @course.activate! unless @course.active?
        format.js
      else
        format.js
      end
    end
  end

  def update
    @course   = Course.find(params[:course_id])
    @planning = @course.plannings.find(params[:id])
    respond_to do |format|
      if @planning.update_attributes(params[:planning])
        format.js
      else
        format.js
      end
    end
  end

  def destroy
    @course   = Course.find(params[:course_id])
    @planning = @course.plannings.where(id: params[:id]).first
    @planning.destroy if @planning.present?
    respond_to do |format|
      format.js
      format.html { redirect_to pro_structure_courses_path(@structure), notice: 'Le créneau a bien été supprimé' }
    end
  end

  private

  def set_dates_and_times
    # Setting time
    if params[:planning]['start_time(4i)'].present? && params[:planning]['start_time(5i)'].present?
      params[:planning][:start_time] = TimeParser.parse_time_string("#{params[:planning]['start_time(4i)']}h#{params[:planning]['start_time(5i)']}")
    end
    if params[:planning]['end_time(4i)'].present? && params[:planning]['end_time(5i)'].present?
      params[:planning][:end_time] = TimeParser.parse_time_string("#{params[:planning]['end_time(4i)']}h#{params[:planning]['end_time(5i)']}")
    end

    if params[:planning][:end_time].blank? && params[:planning][:duration].present?
      params[:planning][:end_time]   = params[:planning][:start_time] + params[:planning][:duration].to_i.minutes
    elsif params[:planning][:end_time].present? &&  params[:planning][:duration].blank?
      params[:planning][:duration]   = TimeParser.duration_from params[:planning][:start_time], params[:planning][:end_time]
    end
  end

  def retrieve_places
    @places = @structure.places
  end

  def load_structure
    @course    = Course.friendly.find(params[:course_lesson_id] || params[:course_training_id] || params[:course_id])
    @structure = @course.structure
  end
end
