# encoding: utf-8
class Pro::TeachersController < InheritedResources::Base

  layout 'admin'

  belongs_to :structure
  load_and_authorize_resource :structure

  def index
    @teacher = Teacher.new
    index!
  end

  def create
    create! do |success, failure|
      success.html { redirect_to structure_teachers_path(@structure) }
    end
  end

  def edit
    @teachers = @structure.teachers
    edit! do |format|
      format.html { render template: 'pro/teachers/index' }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to structure_teachers_path(@structure) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to structure_teachers_path(@structure) }
      failure.html { render template: 'pro/teachers/index' }
    end
  end
end
