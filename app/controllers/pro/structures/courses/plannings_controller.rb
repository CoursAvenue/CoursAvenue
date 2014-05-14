# encoding: utf-8
class Pro::Structures::Courses::PlanningsController < InheritedResources::Base
  layout 'admin'

  before_action :authenticate_pro_admin!
  before_action :load_structure
  before_action :retrieve_teachers
  before_action :retrieve_places

  belongs_to :course
  load_and_authorize_resource :structure, find_by: :slug

  def index
    @planning  = Planning.new
    retrieve_plannings_and_past_plannings
    @planning.teacher = @plannings.first.teacher if @plannings.any?
  end

  def new
    @course   = Course.friendly.find(params[:course_id])
    @planning = @course.plannings.build
    retrieve_plannings_and_past_plannings
    respond_to do |format|
      if request.xhr?
        format.html { render partial: "pro/structures/courses/plannings/#{@course.underscore_name}_form" }
      else
        format.html do
          render template: 'pro/structures/courses/plannings/index'
        end
      end
    end
  end

  def edit
    @planning  = Planning.find(params[:id])
    retrieve_plannings_and_past_plannings
    respond_to do |format|
      if request.xhr?
        format.html { render partial: "pro/structures/courses/plannings/#{@course.underscore_name}_form" }
      else
        format.html { render template: 'pro/structures/courses/plannings/index' }
      end
    end
  end

  def create
    create_or_affect_teacher
    update_place_infos
    @planning           = Planning.new(params[:planning])
    @planning.teacher   = @teacher if @teacher
    @planning.course    = @course
    retrieve_plannings_and_past_plannings
    set_dates_and_times
    respond_to do |format|
      if @planning.save
        @course.activate! unless @course.active?
        format.html { redirect_to pro_structure_courses_path(@structure), notice: 'Votre planning à bien été créé.' }
      else
        format.html { render template: 'pro/structures/courses/plannings/index' }
      end
    end
  end

  def update
    create_or_affect_teacher
    update_place_infos
    @planning        = Planning.find(params[:id])
    @planning.course = @course
    retrieve_plannings_and_past_plannings
    set_dates_and_times
    respond_to do |format|
      if @planning.update_attributes(params[:planning])
        format.html { redirect_to pro_structure_course_plannings_path(@structure, @course), notice: 'Le créneau a bien été modifié' }
        format.js { render nothing: true, status: 200 }
      else
        if @planning.end_date and @planning.end_date < Date.today
          flash[:alert] = 'Le cours ne peut être dans le passé'
        end
        format.html { render template: 'pro/structures/courses/plannings/index', notice: 'Le créneau a bien été mis à jour' }
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_course_plannings_path(@structure, @course), notice: 'Le créneau a bien été supprimé' }
    end
  end

  private

  def retrieve_plannings_and_past_plannings
    if @course.is_lesson?
      @plannings      = @course.plannings.ordered_by_day.order('start_time ASC')
      @past_plannings = []
    else
      @plannings      = @course.plannings.order('start_date ASC, start_time ASC').future
      @past_plannings = @course.plannings.order('start_date ASC, start_time ASC').past
    end
  end

  def update_place_infos
    return if params[:place].blank?
    place              = Place.find params[:planning][:place_id]
    place.info         = params[:place][:info]
    place.private_info = params[:place][:private_info]
    place.save
  end

  def create_or_affect_teacher
    teacher_name = params[:planning].delete :teacher
    if teacher_name.present?
      @teacher = @course.structure.teachers.create(name: teacher_name)
    end
  end

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

  def retrieve_teachers
    @teachers = @structure.teachers
  end

  def retrieve_places
    @places = @structure.places
  end

  def load_structure
    @course    = Course.friendly.find(params[:course_lesson_id] || params[:course_training_id] || params[:course_id])
    @structure = @course.structure
  end
end
