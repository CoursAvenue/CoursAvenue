# encoding: utf-8
class Pro::Structures::OpenCoursesController < Pro::ProController
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  def new
    @course = Course::Open.new structure: @structure
    count      = @structure.prices.individual.count
    all_amount = @structure.prices.individual.map(&:amount).reduce(&:+)
    if all_amount
      @course.common_price = (all_amount / count).to_i
    end
  end

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @courses   = @structure.courses.open_courses.order('created_at ASC')
    respond_to do |format|
      if @structure.parisian?
        format.html
      else
        format.html { redirect_to pro_structure_courses_path(@structure), notice: "Vous n'êtes pas en Île-de-France" }
      end
    end
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

  def update
    @structure = Structure.friendly.find params[:structure_id]
    @course    = @structure.courses.find params[:id]
    respond_to do |format|
      if @course.update_attributes params[:course]
        format.html { redirect_to pro_structure_course_opens_path(@structure), notice: 'Votre cours a bien été mis à jour.' }
      else
        format.html { render :new }
      end
    end
  end

  def destroy
    @structure = Structure.friendly.find params[:structure_id]
    @course    = @structure.courses.find params[:id]
    respond_to do |format|
      if @course.destroy
        format.html { redirect_to pro_structure_course_opens_path(@structure), notice: 'Le cours a bien été supprimé' }
      else
        format.html { redirect_to pro_structure_course_opens_path(@structure), notice: "Le cours n'a pas pu être supprimé" }
      end
    end
  end
end
