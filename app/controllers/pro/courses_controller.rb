# encoding: utf-8
class Pro::CoursesController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  belongs_to :structure

  layout 'admin'

  before_filter :load_structure
  load_and_authorize_resource :structure

  def create
    @course           = Course.new params[:course]
    @course.structure = @structure
    create! do |success, failure|
      success.html { redirect_to pro_course_plannings_path(@course), notice: 'Vous pouvez maintenant créer le planning de ce cours' }
      failure.html { redirect_to new_pro_structure_course(@structure), alert: 'Impossible de créer le cours.' }
    end
  end

  def update
    if params[:course].delete(:delete_image) == '1'
      resource.image.clear
    end
    update! do |success, failure|
      success.html { redirect_to (params[:from] || pro_structure_path(@structure)) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_path(@structure) }
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
