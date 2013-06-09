# encoding: utf-8
class Pro::PlanningsController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  layout 'admin'
  belongs_to :course
  before_filter :load_structure
  load_and_authorize_resource :structure

  def index
    @planning  = Planning.new
    @teachers  = @structure.teachers
    if @course.is_lesson?
      @plannings = @course.plannings.order('week_day ASC, start_time ASC')
    else
      @plannings = @course.plannings.order('start_date ASC, start_time ASC')
    end
  end

  def edit
    @planning  = Planning.find(params[:id])
    @plannings = @course.plannings.reject { |planning| planning == @planning }
    render template: 'pro/plannings/index'
  end

  def create
    if can? :edit, @course
      create_or_affect_teacher
      @planning         = Planning.new(params[:planning])
      @planning.teacher = @teacher if @teacher
      @plannings        = @course.plannings.reject { |planning| planning == @planning }
      @planning.course  = @course
      set_dates_and_times

      respond_to do |format|
        if @planning.save
          format.html { redirect_to pro_course_plannings_path(@course) }
        else
          if @planning.end_date and @planning.end_date < Date.today
            alert = 'Le cours ne peut être dans le passé'
            flash[:alert] = alert
          end
          format.html { render template: 'pro/plannings/index'}
        end
      end
    else
      redirect_to pro_structure_path(@structure), alert: "Votre compte n'est pas encore activé, vous ne pouvez pas éditer les cours actifs"
    end
  end

  def update
    if can? :edit, @course
      create_or_affect_teacher
      @planning        = Planning.find(params[:id])
      @planning.course = @course
      @plannings       = @course.plannings.reject { |planning| planning == @planning }
      set_dates_and_times
      respond_to do |format|
        if @planning.update_attributes(params[:planning])
          format.html { redirect_to pro_course_plannings_path(@course) }
        else
          if @planning.end_date < Date.today
            alert = 'Le cours ne peut être dans le passé'
          end
          flash[:alert] = alert
          format.html { render template: 'pro/plannings/index' }
        end
      end
    else
      redirect_to pro_structure_path(@structure), alert: "Votre compte n'est pas encore activé, vous ne pouvez pas éditer les cours actifs"
    end
  end

  def destroy
    if can? :edit, @course
      destroy! do |success, failure|
        success.html { redirect_to pro_course_plannings_path(@course) }
      end
    else
      redirect_to pro_structure_path(@structure), alert: "Votre compte n'est pas encore activé, vous ne pouvez pas éditer les cours actifs"
    end
  end

  private

  def create_or_affect_teacher
    teacher_name = params[:planning].delete :teacher
    if teacher_name.present?
      @teacher = @course.structure.teachers.create(name: teacher_name)
    end
  end

  def set_dates_and_times
    params[:planning][:start_time]  = TimeParser.parse_time_string("#{params[:planning]['start_time(4i)']}h#{params[:planning]['start_time(5i)']}")  if params[:planning]['start_time(4i)'].present? and params[:planning]['start_time(5i)'].present?
    params[:planning][:end_time]    = TimeParser.parse_time_string("#{params[:planning]['end_time(4i)']}h#{params[:planning]['end_time(5i)']}")  if params[:planning]['end_time(4i)'].present? and params[:planning]['end_time(5i)'].present?

    if params[:planning][:end_time].blank? and params[:planning][:duration].present?
      params[:planning][:end_time]   = params[:planning][:start_time] + params[:planning][:duration].to_i.minutes
    elsif params[:planning][:end_time].present? and  params[:planning][:duration].blank?
      params[:planning][:duration]   = TimeParser.duration_from params[:planning][:start_time], params[:planning][:end_time]
    end
  end

  def load_structure
    @course    = Course.find(params[:course_lesson_id] || params[:course_workshop_id] || params[:course_training_id] || params[:course_id])
    @structure = @course.structure
  end
end
