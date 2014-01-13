# encoding: utf-8
class Pro::Structures::OpenCoursesController < Pro::ProController
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  def new
    @course = Course::Open.new structure: @structure
  end

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @courses   = @structure.courses.open_courses
  end

  def edit
    @course = @structure.courses.open_courses.find params[:id]
  end

  def create
    @course = Course::Open.new params[:course]
    @course.structure = @structure
    respond_to do |format|
      if @course.save
        format.html { redirect_to pro_structure_course_opens_path(@structure), notice: 'Votre cours a été créé, vous pouvez maintenant ajouter des créneaux.' }
      else
        format.html { render :new }
      end
    end
  end

end
