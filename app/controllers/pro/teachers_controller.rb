# encoding: utf-8
class Pro::TeachersController < InheritedResources::Base
  before_action :authenticate_pro_admin!

  layout 'admin'

  belongs_to :structure
  load_and_authorize_resource :structure, except: [:index], find_by: :slug

  def index
    @teacher = Teacher.new
    index!
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
        format.html { render partial: 'pro/teachers/form' }
      else
        format.html { render template: 'pro/teachers/index' }
      end
    end
  end

  def new
    new! do |format|
      if request.xhr?
        format.html { render partial: 'pro/teachers/form' }
      else
        format.html { render template: 'pro/teachers/index' }
      end
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to pro_structure_teachers_path(@structure) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_teachers_path(@structure) }
      failure.html { render template: 'pro/teachers/index' }
    end
  end
end
