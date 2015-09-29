# encoding: utf-8
class Pro::Structures::TeachersController < InheritedResources::Base
  before_action :authenticate_pro_admin!

  layout 'admin'

  belongs_to :structure
  load_and_authorize_resource :structure, except: [:index], find_by: :slug

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @teachers  = @structure.teachers.order('name ASC')
  end

  def create
    create! do |success, failure|
      success.html { redirect_to pro_structure_teachers_path(@structure) }
      failure.html { redirect_to pro_structure_teachers_path(@structure) }
    end
  end

  def edit
    edit! do |format|
      if request.xhr?
        format.html { render partial: 'pro/structures/teachers/form' }
      else
        format.html { redirect_to pro_structure_teachers_path(@structure) }
      end
    end
  end

  def new
    @teachers = @structure.teachers.reject(&:new_record?)
    new! do |format|
      if request.xhr?
        format.html { render partial: 'pro/structures/teachers/form' }
      else
        format.html { render template: 'pro/structures/teachers/index' }
      end
    end
  end

  def update
    if params[:teacher] && params[:teacher].delete(:delete_image) == '1'
      resource.remove_image!
    end
    update! do |success, failure|
      success.html { redirect_to pro_structure_teachers_path(@structure) }
      failure.html { redirect_to pro_structure_teachers_path(@structure) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_teachers_path(@structure) }
      failure.html { render template: 'pro/structures/teachers/index' }
    end
  end
end
