# encoding: utf-8
class Pro::CoursesController < InheritedResources::Base

  layout 'admin'

  before_filter :load_structure
  load_and_authorize_resource :structure

  def create
    create! do |success, failure|
      success.html { redirect_to structure_path(@structure) }
    end
  end

  def update
    if params[:course].delete(:delete_image) == '1'
      @course.image.clear
    end
    update! do |success, failure|
      success.html { redirect_to (params[:from] || structure_path(@structure)) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to structure_path(@structure) }
    end
  end

  private
  def load_structure
    if params[:structure_id]
      @structure = Structure.find(params[:structure_id])
    else
      @course    = Course.find(params[:id])
      @structure = @course.structure
    end
  end
end
