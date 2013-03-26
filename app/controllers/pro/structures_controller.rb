# encoding: utf-8
class Pro::StructuresController < Pro::ProController
  before_filter :authenticate_admin!
  load_and_authorize_resource

  layout 'admin'

  def disable_condition
    @structure        = Structure.find params[:id]
    @structure.update_attribute :has_validated_conditions, false
    @structure.update_attribute :validated_by, nil
    respond_to do |format|
      format.html { redirect_to awaiting_structures_path }
    end
  end

  def validate_condition
    @structure        = Structure.find params[:id]
    @structure.update_attributes params[:structure]
    respond_to do |format|
      format.html { redirect_to structure_path(@structure), notice: "Nous avons bien été avertis. Nous revenons vers vous dans les meilleurs délais." }
    end
  end

  def activate
    @structure        = Structure.find params[:id]
    @structure.update_attribute :active, true
    respond_to do |format|
      format.html { redirect_to awaiting_structures_path }
    end
  end

  def awaiting
    @structures = Structure.where{(active == false) | (has_validated_conditions == true)}.order('created_at DESC').all
  end

  def index
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
    @admin     = @structure.admins.first || Admin.new
  end

  def new
    @structure = Structure.new
    @admin     = current_admin
    @structure.admins << @admin
  end

  def update
    @structure = Structure.find params[:id]
    @admin     = (params[:admin][:id].blank? ? ::Admin.new : ::Admin.find(params[:admin].delete(:id)))
    @structure.admins << @admin

    if !@admin.new_record? and params[:admin][:password].blank?
      params[:admin].delete :password
      params[:admin].delete :password_confirmation
    end

    respond_to do |format|
      has_saved = @admin.update_attributes(params[:admin])
      has_saved = has_saved && @structure.save
      if has_saved
        format.html { redirect_to edit_structure_path @structure }
      else
        format.html { render action: 'edit' }
      end
    end
  end


  def create
    @admin           = (params[:admin][:id].blank? ? ::Admin.new : ::Admin.find(params[:admin].delete(:id)))
    @structure       = Structure.new(params[:structure])
    @structure.admins << @admin
    @admin.structure = @structure
    if !@admin.new_record? and params[:admin][:password].blank?
      params[:admin].delete :password
      params[:admin].delete :password_confirmation
    end
    respond_to do |format|
      has_saved = @admin.update_attributes(params[:admin])
      has_saved = has_saved && @structure.save
      if has_saved
        format.html { redirect_to structure_teachers_path(@admin.structure), :notice => t("pro.structures.create.create_teacher") }
      else
        flash[:alert] = "Il nous manque quelques informations pour continuer"
        format.html { render action: 'new'}
      end
    end
  end
end
