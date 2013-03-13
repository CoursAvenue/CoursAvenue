# encoding: utf-8
class Pro::PricesController < InheritedResources::Base#Pro::ProController
  layout 'admin'
  belongs_to :course
  before_filter :load_structure
  load_and_authorize_resource :structure

  def index
    @price = Price.new
    index!
  end

  def edit
    @price = Price.find(params[:id])
    @price = @course.plannings
    render template: 'pro/plannings/index'
  end

  def create
    create! do |success, failure|
      success.html { redirect_to course_prices_path(@course) }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to course_prices_path(@course) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to course_prices_path(@course) }
    end
  end


  private
  def load_structure
    @course    = Course.find(params[:course_lesson_id] || params[:course_workshop_id] || params[:course_training_id] || params[:course_id])
    @structure = @course.structure
  end
end
