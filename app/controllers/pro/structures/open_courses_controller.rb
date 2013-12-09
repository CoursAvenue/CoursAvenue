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
    azd?
  end

end
