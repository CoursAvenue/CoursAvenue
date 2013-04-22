# encoding: utf-8
class Pro::StructuresController < Pro::ProController
  before_filter :authenticate_pro_admin!, except: [:select, :show]
  load_and_authorize_resource except: [:select, :show]
  layout 'admin'

  def select
    @structures = Structure.all
  end

  def disable_condition
    @structure        = Structure.find params[:id]
    @structure.update_attribute :has_validated_conditions, false
    @structure.update_attribute :validated_by, nil
    respond_to do |format|
      format.html { redirect_to awaiting_pro_structures_path }
    end
  end

  def validate_condition
    @structure        = Structure.find params[:id]
    respond_to do |format|
      if @structure.update_attributes params[:structure]
        format.html { redirect_to pro_structure_path(@structure), notice: "Nous avons bien été avertis. Nous revenons vers vous dans les meilleurs délais." }
      else
        format.html { redirect_to edit_pro_structure_path(@structure), alert: "Vous devez remplir toutes vos informations" }
      end
    end
  end

  def activate
    @structure        = Structure.find params[:id]
    @structure.active = true
    @structure.courses.each do |course|
      course.active = true
      course.save
    end

    respond_to do |format|
      if @structure.save
        format.html { redirect_to pro_structures_path }
      else
        format.html { redirect_to pro_structures_path, alert: 'Les informations de la structure ne sont pas complètes.' }
      end
    end
  end

  def awaiting
    @structures = Structure.where{(active == false) | (has_validated_conditions == true)}.order('created_at DESC').all
  end

  def index
    @structures = Structure.order('name ASC').all
  end

  def validation
    @structure = Structure.find params[:id]
  end

  def show
    @structure = Structure.find params[:id]
    @courses   = @structure.courses
    respond_to do |format|
      if @structure.places.empty?
        format.html { redirect_to new_pro_structure_place_path(@structure), notice: "Vous devez d'abord créé des lieux pour vos cours."}
      # elsif @courses.empty?
      #   format.html{ redirect_to new_pro_structure_course_path(@structure) }
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
    @admin     = current_pro_admin
    @structure.admins << @admin
  end

  def update
    @structure = Structure.find params[:id]
    if params[:structure].delete(:delete_image) == '1'
      resource.image.clear
    end
    if current_pro_admin.super_admin?
      respond_to do |format|
        if @structure.update_attributes params[:structure]
          format.html { redirect_to edit_pro_structure_path @structure }
        else
          format.html { render action: 'edit' }
        end
      end
    else
      @admin     = (params[:admin][:id].blank? ? ::Admin.new : ::Admin.find(params[:admin].delete(:id)))
      @structure.admins << @admin

      if !@admin.new_record? and params[:admin][:password].blank?
        params[:admin].delete :password
        params[:admin].delete :password_confirmation
      end

      respond_to do |format|
        has_saved = @admin.update_attributes(params[:admin])
        has_saved = has_saved && @structure.update_attributes(params[:structure])
        if has_saved
          format.html { redirect_to edit_pro_structure_path @structure }
        else
          format.html { render action: 'edit' }
        end
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
        format.html { redirect_to pro_structure_teachers_path(@admin.structure), :notice => t("pro.structures.create.create_teacher") }
      else
        flash[:alert] = "Il nous manque quelques informations pour continuer"
        format.html { render action: 'new'}
      end
    end
  end

  def destroy
    @structure = Structure.find params[:id]
    @structure.active = false
    @structure.courses.each do |course|
      course.active = false
      course.save
    end
    respond_to do |format|
      if @structure.save
        format.html { redirect_to pro_structures_path }
      else
        format.html { redirect_to pro_structures_path, alert: 'Les informations de la structure ne sont pas complètes.' }
      end
    end
  end

end
