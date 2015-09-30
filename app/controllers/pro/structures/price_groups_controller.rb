# encoding: utf-8
  load_and_authorize_resource :structure

  def index
  end

  def new
    @price_group = @structure.price_groups.build(course_type: params[:course_type], name: params[:name])
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
    @price_group = @structure.price_groups.build
    @price_group.localized.assign_attributes(params[:price_group])
    @course      = @structure.courses.find(params[:course_id]) if params[:course_id].present?
    respond_to do |format|
      if @price_group.save
        if @course
          @course.price_group = @price_group
          @course.save
        end
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
    else
      redirect_to pro_structure_price_groups_path(@structure)
    end
  end

  def update
    @price_group = @structure.price_groups.find params[:id]
    @course      = @structure.courses.find(params[:course_id]) if params[:course_id].present?
    respond_to do |format|
      if @price_group.localized.update_attributes params[:price_group]
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
    respond_to do |format|
      if @course.save
        retrieve_non_affected_courses
        format.js { render 'reload_price_group' }
      else
        format.js { render nothing: true, status: 500 }
      end
    end
  end

  def add_course
    @course = @structure.courses.find params[:course_id]
    @price_group = @structure.price_groups.find params[:id]
    @course.price_group = @price_group
    respond_to do |format|
      if @course.save
        retrieve_non_affected_courses
        format.js { render 'reload_price_group' }
      else
        format.js { render nothing: true, status: 500 }
      end
    end
  end

  def destroy
    @price_group = @structure.price_groups.find params[:id]
    @price_group.destroy
    retrieve_non_affected_courses
    respond_to do |format|
      format.html { redirect_to pro_structure_price_groups_path(@structure), notice: 'La grille tarifaire a bien été supprimée' }
      format.js
    end
  end

  private

  def retrieve_prices
    @per_courses        = @price_group.book_tickets.select{|price| price.number == 1}
    @book_tickets       = @price_group.book_tickets.reject{|price| price.number == 1}
    @discounts          = @price_group.discounts
    @subscriptions      = @price_group.subscriptions
    @registrations      = @price_group.registrations
    @premium_offers     = @price_group.premium_offers
    @trial              = @price_group.trial || @price_group.prices.build(type: 'Price::Trial')

    8.times  { @per_courses       << @price_group.prices.build(type: 'Price::BookTicket', number: 1) }
    8.times  { @book_tickets       << @price_group.prices.build(type: 'Price::BookTicket', number: 2) }
    10.times { @subscriptions      << @price_group.prices.build(type: 'Price::Subscription',) }
    10.times { @premium_offers     << @price_group.prices.build(type: 'Price::PremiumOffer',) }
    6.times  { @discounts          << @price_group.prices.build(type: 'Price::Discount',) }
    6.times  { @registrations      << @price_group.prices.build(type: 'Price::Registration',) }
    @per_courses      = @per_courses.map(&:localized)
    @book_tickets     = @book_tickets.map(&:localized)
    @discounts        = @discounts.map(&:localized)
    @subscriptions    = @subscriptions.map(&:localized)
    @registrations    = @registrations.map(&:localized)
    @premium_offers   = @premium_offers.map(&:localized)
    @trial            = @trial.localized
  end

  def retrieve_non_affected_courses
    if @price_group.for_regular_course?
      @courses = @structure.courses.regulars.select{ |course| course.price_group.nil? }
    else
      @courses = @structure.courses.trainings.select{ |course| course.price_group.nil? }
    end
  end
end
