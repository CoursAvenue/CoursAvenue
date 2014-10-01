# encoding: utf-8
class Pro::Structures::CoursesController < Pro::ProController
  layout 'admin'

  before_action :authenticate_pro_admin!
  before_action :load_structure

  load_and_authorize_resource :structure, find_by: :slug

  def new
    @course = @structure.courses.build(type: params[:type])
    if request.xhr?
      render partial: 'form', layout: false
    end
  end

  def index
    redirect_to regular_pro_structure_courses_path(@structure)
  end

  def regular
    @courses = @structure.courses.without_open_courses.order('name ASC')
  end

  def trainings
    @courses = @structure.courses.without_open_courses.order('name ASC')
  end

  def discovery_pass
    @courses = @structure.courses.without_open_courses.order('name ASC')
  end

  def activate_ok_nico
    @course = Course.friendly.find params[:id]
    respond_to do |format|
      @course.update_column :ok_nico, true
      format.js { render nothing: true }
    end
  end

  def disable_ok_nico
    @course = Course.friendly.find params[:id]
    respond_to do |format|
      @course.update_column :ok_nico, false
      format.js { render nothing: true }
    end
  end

  def activate
    @course = Course.friendly.find params[:id]
    respond_to do |format|
      if @course.activate!
        @course.plannings.map(&:index)
        if @course.is_open?
          format.html { redirect_to (request.referrer || pro_open_courses_path), notice: 'Le cours a bien été activé' }
          format.js { render nothing: true }
        else
          format.html { redirect_to (request.referrer || pro_structure_courses_path(@structure)), notice: 'Le cours sera visible sur CoursAvenue dans quelques minutes' }
        end
      else
        format.html { redirect_to pro_structure_courses_path(@structure), alert: "Le cours n'a pu être mis en ligne.<br>Assurez vous que les tarif et les plannings sont bien renseignés." }
        format.js { render nothing: true }
      end
    end
  end

  def disable
    @course = Course.friendly.find params[:id]
    @course.active = false
    respond_to do |format|
      if @course.save
        @course.plannings.map(&:index)
        if @course.is_open?
          format.js { render nothing: true }
          format.html { redirect_to pro_open_courses_path, notice: 'Le cours a bien été activé' }
        else
          format.js { render nothing: true }
          format.html { redirect_to pro_structure_courses_path(@structure), notice: "Le cours n'est plus affiché sur CoursAvenue" }
        end
      else
        format.js { render nothing: true }
        format.html { redirect_to pro_structure_courses_path(@structure), alert: "Le cours n'a pu être mis hors ligne. Assurez vous que les tarif et les plannings sont bien renseignés." }
      end
    end
  end

  def edit
    @course = Course.friendly.find params[:id]
    if request.xhr?
      render partial: 'form', layout: false
    end
  end

  def ask_for_deletion
    @course = Course.friendly.find params[:id]
    if request.xhr?
      render layout: false
    end
  end

  def create
    @course           = Course.new params[:course]
    @course.structure = @structure
    respond_to do |format|
      if @course.save
        format.html { redirect_to pro_structure_course_prices_path(@structure, @course), notice: 'Vous pouvez maintenant définir les tarifs pour ce cours' }
        format.js
      else
        format.html { render action: :new}
        format.js
      end
    end
  end

  def update
    @course = @structure.courses.friendly.find params[:id]
    respond_to do |format|
      if @course.update_attributes params[:course]
        format.html { redirect_to pro_structure_courses_path(@structure), notice: 'Le cours a bien été mis à jour' }
        format.json { render json: {}, status: 200 }
        format.js
      else
        format.html { render action: :new}
        format.json { render json: {}, status: 500 }
        format.js
      end
    end
  end

  def destroy
    @course = Course.friendly.find params[:id]
    respond_to do |format|
      if @course.destroy
        format.html { redirect_to pro_structure_courses_path(@structure), notice: "Le cours a bien été supprimé" }
        format.js
      else
        format.html { redirect_to pro_structure_courses_path(@structure), alert: "Une erreur s'est produite" }
        format.js
      end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end
end
