# encoding: utf-8
class Pro::Structures::PriceGroupsController < Pro::ProController
  layout 'admin'

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure

  def index
  end

  def new
    @price_group = @structure.price_groups.build(course_type: params[:course_type])
    retrieve_prices
    if request.xhr?
      render partial: 'form', layout: false
    end
  end

  def show
    @price_group = @structure.price_groups.find params[:id]
    if request.xhr?
      render layout: false
    end
  end

  def ask_for_deletion
    @price_group = @structure.price_groups.find params[:id]
    if request.xhr?
      render layout: false
    end
  end

  def create
    @price_group = @structure.price_groups.build(params[:price_group])
    respond_to do |format|
      if @price_group.save
        format.html { redirect_to pro_structure_price_groups_path(@structure) }
        format.js
      else
        retrieve_prices
        # format.html { render template: 'pro/structures/courses/prices/index' }
        format.js
      end
    end
  end

  def edit
    @price_group = @structure.price_groups.find params[:id]
    retrieve_prices
    if request.xhr?
      render partial: 'form', layout: false
    end
  end

  def update
    @price_group = @structure.price_groups.find params[:id]
    respond_to do |format|
      if @price_group.update_attributes params[:price_group]
        format.html { redirect_to pro_structure_price_groups_path(@structure) }
        format.js
      else
        retrieve_prices
        # format.html { render template: 'pro/structures/courses/prices/index' }
        format.js
      end
    end
  end

  def remove_course
    @course      = @structure.courses.find params[:course_id]
    @price_group = @structure.price_groups.find params[:id]
    @course.price_group = nil
    @course.save
    retrieve_non_affected_courses
    respond_to do |format|
      format.js { render 'reload_price_group' }
    end
  end

  def add_course
    @course = @structure.courses.find params[:course_id]
    @price_group = @structure.price_groups.find params[:id]
    @price_group.courses << @course
    @price_group.save
    retrieve_non_affected_courses
    respond_to do |format|
      format.js { render 'reload_price_group' }
    end
  end


  def destroy
    @price_group = @structure.price_groups.find params[:id]
    @price_group.destroy
    respond_to do |format|
      format.html { redirect_to pro_structure_price_groups_path(@structure), notice: 'La grille tarifaire a bien été supprimée' }
      format.js
    end
  end

  private

  def retrieve_prices
    @book_tickets       = @price_group.book_tickets
    @discounts          = @price_group.discounts
    @subscriptions      = @price_group.subscriptions
    @registrations      = @price_group.registrations
    @premium_offers     = @price_group.premium_offers
    @trial              = @price_group.trial || @price_group.prices.build(type: 'Price::Trial')

    8.times  { @book_tickets       << @price_group.prices.build(type: 'Price::BookTicket', number: 1) }
    10.times { @subscriptions      << @price_group.prices.build(type: 'Price::Subscription',) }
    10.times { @premium_offers     << @price_group.prices.build(type: 'Price::PremiumOffer',) }
    6.times  { @discounts          << @price_group.prices.build(type: 'Price::Discount',) }
    6.times  { @registrations      << @price_group.prices.build(type: 'Price::Registration',) }
  end

  def retrieve_non_affected_courses
    if @price_group.for_lesson?
      @courses = @structure.courses.lessons.select{ |course| course.price_group.nil? }
    else
      @courses = @structure.courses.trainings.select{ |course| course.price_group.nil? }
    end
  end

end
