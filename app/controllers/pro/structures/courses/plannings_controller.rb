# encoding: utf-8
class Pro::Structures::Courses::PlanningsController < InheritedResources::Base
  layout 'admin'

  before_action :authenticate_pro_admin!
  before_action :load_structure
  before_action :retrieve_teachers
  before_action :retrieve_places

  belongs_to :course
  load_and_authorize_resource :structure, find_by: :slug

  def duplicate
    @planning            = Planning.find params[:id]
    @course              = Course.friendly.find params[:course_id]
    @duplicate_planning  = @planning.duplicate
    respond_to do |format|
      if @duplicate_planning.save
        session[:duplicate]              = true
        session[:duplicated_planning_id] = @duplicate_planning.id
        format.html { redirect_to pro_structure_course_plannings_path(@structure, @course), notice: 'Le planning à bien été dupliqué.' }
      else
        format.html { redirect_to pro_structure_course_plannings_path(@structure, @course), notice: "Le planning n'a pu être dupliqué." }
      end
    end
  end

  def index
    @planning  = Planning.new
    retrieve_plannings_and_past_plannings
    @planning.teacher = @plannings.first.teacher if @plannings.any?
  end

  def new
    @course    = Course.friendly.find(params[:course_id])
    @planning  = Planning.new
    retrieve_plannings_and_past_plannings
    respond_to do |format|
      if request.xhr?
        format.html { render partial: "pro/structures/courses/plannings/#{@course.underscore_name}_form" }
      else
        format.html do
          if @course.is_open?
            redirect_to pro_structure_course_opens_path(@structure)
          else
            render template: 'pro/structures/courses/plannings/index'
          end
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
        @course.activate! unless @course.active? or @course.is_open?
        if @course.is_open?
          format.html { redirect_to pro_structure_course_opens_path(@course.structure), notice: 'Votre planning à bien été créé.' }
        else
          format.html { redirect_to pro_structure_course_plannings_path(@structure, @course), notice: 'Votre planning à bien été créé.' }
        end
      else
        if @course.is_open?
          format.html { redirect_to pro_structure_course_opens_path(@course.structure), error: "Le créneau n'a pas pu être créé, avez-vous rempli tous les champs ?" }
        else
          format.html { render template: 'pro/structures/courses/plannings/index' }
        end
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
        if @course.is_open?
          format.html { redirect_to pro_structure_course_opens_path(@course.structure), notice: 'Le créneau a bien été modifié' }
        else
          format.html { redirect_to pro_structure_course_plannings_path(@structure, @course), notice: 'Le créneau a bien été modifié' }
        end
        format.js { render nothing: true, status: 200 }
      else
        if @planning and @planning.end_date < Date.today
          flash[:alert] = 'Le cours ne peut être dans le passé'
        end
        format.html { render template: 'pro/structures/courses/plannings/index', notice: 'Le créneau a bien été mis à jour' }
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      if @course.is_open?
        success.html { redirect_to pro_structure_course_opens_path(@course.structure), notice: 'Le créneau a bien été supprimé' }
      else
        success.html { redirect_to pro_structure_course_plannings_path(@structure, @course), notice: 'Le créneau a bien été supprimé' }
      end
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
    @course    = Course.friendly.find(params[:course_open_id] || params[:course_lesson_id] || params[:course_workshop_id] || params[:course_training_id] || params[:course_id])
    @structure = @course.structure
  end
end
