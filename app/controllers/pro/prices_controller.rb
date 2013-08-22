# encoding: utf-8
class Pro::PricesController < InheritedResources::Base#Pro::ProController
  before_filter :authenticate_pro_admin!

  layout 'admin'

  belongs_to :course
  before_filter :load_structure
  load_and_authorize_resource :structure

  def index
    @other_courses = @structure.courses.reject{|c| c == @course}
    @book_tickets  = @course.book_tickets
    @discounts     = @course.discounts
    @subscriptions = @course.subscriptions
    @registrations = @course.registrations
    # If the course doesn't have a individual price, build one by default
    unless @book_tickets.select{|b| b.number == 1}.any?
      @book_tickets  << ::Price::BookTicket.new(course: @course, number: 1)
    end
    @book_tickets = @book_tickets.sort_by(&:number)
    8.times { @book_tickets  << ::Price::BookTicket.new(course: @course)}
    4.times { @subscriptions << Price::Subscription.new(course: @course) }
    6.times { @discounts     << Price::Discount.new(course: @course) }
    3.times { @registrations << Price::Registration.new(course: @course) }
    index!
  end

  def edit
    @price        = Price.find(params[:id])
    @book_ticket  = BookTicket.new
    @prices       = @course.prices.reject{|price| price.new_record? or price == @price }
    @book_tickets = @course.book_tickets
    render template: 'pro/prices/index'
  end

  def create
    @prices = @course.prices.reject(&:new_record?)
    create! do |success, failure|
      success.html { redirect_to pro_course_prices_path(@course) }
      failure.html { render template: 'pro/prices/index' }
    end
  end

  def update
    @prices = @course.prices.reject(&:new_record?)
    update! do |success, failure|
      success.html { redirect_to pro_course_prices_path(@course) }
      failure.html { render template: 'pro/prices/index' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_course_prices_path(@course) }
    end
  end


  private
  def load_structure
    @course    = Course.find(params[:course_lesson_id] || params[:course_workshop_id] || params[:course_training_id] || params[:course_id])
    @structure = @course.structure
  end
end
