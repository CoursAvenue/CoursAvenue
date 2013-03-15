# encoding: utf-8
class Pro::CoursesController < InheritedResources::Base
  before_filter :authenticate_admin!
  belongs_to :structure

  layout 'admin'

  before_filter :load_structure
  load_and_authorize_resource :structure

  def create
    create! do |success, failure|
      success.html { redirect_to course_plannings_path(@course), notice: 'Vous pouvez maintenant créer le planning de ce cours' }
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
