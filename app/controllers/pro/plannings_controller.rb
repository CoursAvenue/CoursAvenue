# encoding: utf-8
class Pro::PlanningsController < InheritedResources::Base#Pro::ProController
  layout 'admin'
  nested_belongs_to :structure, :course
  load_and_authorize_resource :structure

  def index
    @planning = Planning.new
    index!
  end

  def edit
    @planning  = Planning.find(params[:id])
    @plannings = @course.plannings
    render template: 'pro/plannings/index'
  end

  def create
    @planning        = Planning.new(params[:plannings])
    @planning.course = @course
    set_dates_and_times

    respond_to do |format|
      if @planning.save
        format.html { redirect_to structure_course_plannings_path(@structure, @course) }
      else
        format.html { render template: 'pro/plannings/index' }
      end
    end
  end

  def update
    @planning        = Planning.find(params[:id])
    @planning.course = @course
    set_dates_and_times

    respond_to do |format|
      if @planning.update_attributes(params[:plannings])
        format.html { redirect_to structure_course_plannings_path(@structure, @course) }
      else
        format.html { render template: 'pro/plannings/index' }
      end
    end  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to structure_course_plannings_path(@structure, @course) }
    end
  end

  private
  def set_dates_and_times
    if @course.is_lesson?
    elsif @course.is_workshop?
      start_time                      = TimeParser.parse_time_string params[:plannings][:start_time]
      duration                        = TimeParser.parse_time_string params[:plannings][:duration]
      params[:plannings][:end_time]   = TimeParser.end_time_from_duration(start_time, duration)
      params[:plannings][:start_time] = start_time
      params[:plannings][:duration]   = duration
    elsif @course.is_training?
    end
  end
end
