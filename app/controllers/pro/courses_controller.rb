# encoding: utf-8
class Pro::CoursesController < InheritedResources::Base

  layout 'admin'

  belongs_to :structure
  load_and_authorize_resource :structure

  def create
    create! do |success, failure|
      success.html { redirect_to structure_courses_path(@structure) }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to structure_courses_path(@structure) }
    end
  end
end
