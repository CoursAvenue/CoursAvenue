# encoding: utf-8
class Pro::CoursesController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  before_filter :load_structure

  layout 'admin'

  load_and_authorize_resource :structure, except: [:create, :update]

  def index
    @structure = Structure.find params[:structure_id]
    @courses   = @structure.courses.order('name ASC')
  end

  def duplicate
    @course = Course.find params[:id]
    @course.duplicate!
    redirect_to pro_structure_courses_path(@structure), notice: "Le cours à bien été dupliqué."
  end

  def activate
    @course = Course.find params[:id]
    if @course.activate!
      redirect_to pro_structure_courses_path(@structure), notice: "Le cours sera visible sur CoursAvenue dans quelques minutes"
    else
      redirect_to pro_structure_courses_path(@structure), alert: "Le cours n'a pu être mis en ligne.<br>Assurez vous que le tarif et le planning sont bien renseignés."
    end
  end

  def disable
    @course = Course.find params[:id]
    if @course.update_attribute :active, false
      redirect_to pro_structure_courses_path(@structure), notice: "Le cours n'est plus affiché sur CoursAvenue"
    else
      redirect_to pro_structure_courses_path(@structure), alert: "Le cours n'a pu être mis hors ligne. Assurez vous que le tarif et le planning sont bien renseignés."
    end
  end

  def edit
    edit!
  end

  def create
    @course           = Course.new params[:course]
    @course.structure = @structure
    create! do |success, failure|
      success.html { redirect_to pro_course_prices_path(@course), notice: 'Vous pouvez maintenant définir les tarifs pour ce cours' }
      failure.html { render template: 'pro/courses/form' }
    end
  end

  def update
    authorize! :edit, @course
    if params[:course].delete(:delete_image) == '1'
      resource.image.clear
    end
    update! do |success, failure|
      if params[:course][:prices_attributes].any?
        success.html { redirect_to pro_course_prices_path(@course), notice: 'Les tarifs ont bien été mis à jour' }
        failure.html { render template: 'pro/prices/index' }
      else
        success.html { redirect_to pro_structure_courses_path(@structure), notice: 'Le cours à bien été mis à jour' }
        failure.html { render template: 'pro/courses/form' }
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_courses_path(@structure) }
    end
  end

  private

  def load_structure
    if params[:structure_id]
      @structure = Structure.find(params[:structure_id])
    else
      @course    = Course.find(params[:id]) if params[:id]
      @structure = @course.structure
    end
  end
end
