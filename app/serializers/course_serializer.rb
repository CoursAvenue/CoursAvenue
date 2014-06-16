class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper
  include PlanningsHelper

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :description, :type, :start_date, :end_date, :min_price_amount, :min_price_libelle, :data_url, :subjects,
             :has_free_trial_lesson, :event_type, :best_price, :is_individual, :search_term, :is_lesson, :frequency,
             :cant_be_joined_during_year, :no_class_during_holidays, :teaches_at_home, :teaches_at_home_radius,
             :premium_offers, :book_tickets, :discounts, :registrations, :subscriptions, :trials,
             :has_premium_prices, :premium, :on_appointment, :course_location, :min_age_for_kid, :max_age_for_kid,
             :audiences, :levels, :is_private

  has_many :plannings, serializer: PlanningSerializer

  def plannings
    @options[:plannings] || object.plannings.visible.future.ordered_by_day
  end

  def has_free_trial_lesson
    object.has_free_trial_lesson?
  end

  def is_individual
    object.is_individual?
  end

  def teaches_at_home
    object.teaches_at_home?
  end

  def teaches_at_home_radius
    object.structure.teaches_at_home_radius
  end

  def best_price
    not object.best_price.nil?
  end

  def min_price_amount
    number_to_currency(object.best_price.try(:amount)) if object.best_price
  end

  def min_price_libelle
    object.best_price.localized_libelle.downcase if object.best_price
  end

  def type
    object.type_name
  end

  def is_lesson
    object.is_lesson?
  end

  def start_date
    I18n.l(object.start_date, format: :semi_short) if object.start_date
  end

  def end_date
    I18n.l(object.end_date, format: :semi_short) if object.end_date
  end

  def data_url
    structure_course_path((@options[:structure] || object.structure), object)
  end

  def subjects
    object.subjects.map(&:name).join(', ')
  end

  def event_type
    if object.other_event_type?
      object.event_type_description
    else
      object.event_type
    end
  end

  def search_term
    @options[:search_term] if @options[:search_term].present?
  end

  def frequency
    I18n.t(object.frequency) if object.frequency.present?
  end

  def has_premium_prices
    object.has_premium_prices?
  end

  def premium
    object.structure.premium?
  end

  def registrations
    object.prices.registrations.map{ |price| PriceSerializer.new(price) }
  end

  def premium_offers
    object.prices.premium_offers.map{ |price| PriceSerializer.new(price) }
  end

  def subscriptions
    object.prices.subscriptions.map{ |price| PriceSerializer.new(price) }
  end

  def book_tickets
    object.prices.book_tickets.map{ |price| PriceSerializer.new(price) }
  end

  def discounts
    object.prices.discounts.map{ |price| PriceSerializer.new(price) }
  end

  def trials
    object.prices.trials.map{ |price| PriceSerializer.new(price) }
  end

  def course_location
    return '' unless object.is_private?
    string = "Le cours se déroule "
    if object.teaches_at_home? and object.home_place and object.place
       string << "dans 2 lieux : "
    else
       string << "à l'adresse : "
    end
    if object.teaches_at_home? and object.home_place
      string << "À domicile (#{object.home_place.city.name}, #{object.home_place.radius})"
    end
    if object.teaches_at_home? and object.home_place and object.place
      string << " et"
    end
    if object.place
      string << object.place.address
    end
    string
  end

  def levels
    join_levels_text(object) if object.is_private?
  end

  def audiences
    join_audiences(object) if object.is_private?
  end

  def is_private
    object.is_private?
  end

end
