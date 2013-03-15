# encoding: utf-8
class Pro::StructuresController < Pro::ProController
  before_filter :authenticate_admin!
  load_and_authorize_resource

  layout 'admin'

  def index
    authorize! :manage, Structure
    @structures = Structure.order('name ASC').all
  end

  def show
    @structure = Structure.find params[:id]
    @courses   = @structure.courses
    respond_to do |format|
      if @structure.places.empty?
        format.html { redirect_to new_structure_place_path(@structure), notice: "Vous devez d'abord créé des lieux pour vos cours."}
      elsif @courses.empty?
        format.html{ redirect_to new_structure_course_path(@structure) }
      else
        format.html
      end
    end
  end

  def edit
    @structure = Structure.find(params[:id])
    authorize! :edit, @structure
    @admin     = @structure.admins.first || Admin.new
  end

  def new
    @structure = Structure.new
  end

  def update
    @structure = Structure.find params[:id]
    authorize! :manage, @structure

    @admin     = @structure.admins.first || Admin.new

    respond_to do |format|
      if @structure.update_attributes params[:structure]
        format.html { redirect_to edit_structure_path @structure }
      else
        format.html { render action: 'edit' }
      end
    end
  end
end
