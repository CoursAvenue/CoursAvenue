# encoding: utf-8
class Pro::CoursesController < InheritedResources::Base
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  load_and_authorize_resource :structure, except: [:create, :update], find_by: :slug

  def new
    @course = @structure.courses.build
  end

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @courses   = @structure.courses.without_open_courses.order('name ASC')
  end

  def copy_prices_from
    @course                   = Course.friendly.find params[:id]
    @course_to_duplicate_from = Course.friendly.find params[:course_id]
    @course.copy_prices_from!(@course_to_duplicate_from)
    redirect_to pro_course_prices_path(@course), notice: "Les tarifs ont été mis à jour."
  end

  def duplicate
    @course = Course.friendly.find params[:id]
    duplicate_course = @course.duplicate!
    session[:duplicate]            = true
    session[:duplicated_course_id] = duplicate_course.id
    redirect_to pro_structure_courses_path(@structure), notice: "Le cours à bien été dupliqué."
  end

  def activate
    @course = Course.friendly.find params[:id]
    if @course.activate!
      redirect_to pro_structure_courses_path(@structure), notice: "Le cours sera visible sur CoursAvenue dans quelques minutes"
    else
      redirect_to pro_structure_courses_path(@structure), alert: "Le cours n'a pu être mis en ligne.<br>Assurez vous que le tarif et le planning sont bien renseignés."
    end
  end

  def disable
    @course = Course.friendly.find params[:id]
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
    had_price_before = @course.prices.any?
    update! do |success, failure|
      if params[:course][:prices_attributes].present?
        if had_price_before
          success.html { redirect_to pro_course_prices_path(@course), notice: 'Les tarifs ont bien été mis à jour' }
        else
          success.html { redirect_to pro_course_plannings_path(@course), notice: 'Les tarifs ont bien été mis ajouté au cours, renseignez maintenant votre planning' }
        end
        failure.html { render template: 'pro/prices/index' }
      else
        success.html { redirect_to pro_structure_courses_path(@structure), notice: 'Le cours à bien été mis à jour' }
        failure.html { render template: 'pro/courses/form' }
        success.json { render json: { done: true } }
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
      @structure = Structure.friendly.find(params[:structure_id])
    else
      @course    = Course.friendly.find(params[:id]) if params[:id]
      @structure = @course.structure
    end
  end
end
