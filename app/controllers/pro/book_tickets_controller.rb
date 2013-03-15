# encoding: utf-8
class Pro::BookTicketsController < InheritedResources::Base#Pro::ProController
  before_filter :authenticate_admin!

  layout 'admin'

  belongs_to :course
  before_filter :load_structure, :load_prices
  load_and_authorize_resource :structure

  def edit
    edit! do |format|
      @book_tickets = @course.book_tickets.reject{|book_ticket| book_ticket == @book_ticket}
      format.html { render template: 'pro/prices/index' }
    end
  end
  def create
    create! do |success, failure|
      success.html { redirect_to course_prices_path(@course) }
      failure.html { render template: 'pro/prices/index' }
    end
  end

  def update
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
  def load_prices
    @prices = @course.prices
  end
  def load_structure
    @course    = Course.find(params[:course_lesson_id] || params[:course_workshop_id] || params[:course_training_id] || params[:course_id])
    @structure = @course.structure
  end
end
