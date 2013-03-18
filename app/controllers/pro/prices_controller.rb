# encoding: utf-8
class Pro::PricesController < InheritedResources::Base#Pro::ProController
  before_filter :authenticate_admin!

  layout 'admin'

  belongs_to :course
  before_filter :load_structure
  load_and_authorize_resource :structure

  def index
    @price       = Price.new
    @book_ticket = BookTicket.new
    @book_tickets = @course.book_tickets
    index!
  end

  def edit
    @price        = Price.find(params[:id])
    @book_ticket  = BookTicket.new
    @prices       = @course.prices
    @book_tickets = @course.book_tickets
    render template: 'pro/prices/index'
  end

  def create
    @prices = @course.prices.reject(&:new_record?)
    create! do |success, failure|
      success.html { redirect_to course_prices_path(@course) }
      failure.html { render template: 'pro/prices/index' }
    end
  end

  def update
    @prices = @course.prices.reject(&:new_record?)
    update! do |success, failure|
      success.html { redirect_to course_prices_path(@course) }
      failure.html { render template: 'pro/prices/index' }
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
