class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper
  include PlanningsHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :description, :description_short, :type, :start_date, :end_date, :min_price_amount, :min_price_libelle, :data_url, :subjects,
             :has_free_trial_lesson, :event_type, :best_price, :is_individual, :search_term, :is_lesson, :frequency,
             :cant_be_joined_during_year, :no_class_during_holidays, :teaches_at_home, :teaches_at_home_radius,
             :has_premium_prices, :premium, :on_appointment, :course_location, :min_age_for_kid, :max_age_for_kid,
             :audiences, :levels, :is_private, :details, :prices, :premium_prices, :prices_length


  has_many :plannings,      serializer: PlanningSerializer
  has_many :prices,         serializer: PriceSerializer
  has_many :premium_prices, serializer: PriceSerializer

  def plannings
    @options[:plannings] || object.plannings.visible.future.ordered_by_day
  end

  def description_short
    truncate(object.description, :length => 200, :separator => ' ') if object.description
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

  # TODO improve with subject_strings ?
  def subjects
    _subjects = []
    object.subjects.map(&:root).uniq.each do |root_subject|
      child_subjects = object.subjects.at_depth(2).order('name ASC').select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      _subjects << {
        root_name: root_subject.name,
        child_names: child_subjects.map(&:name).join(', '),
        icon: ActionController::Base.helpers.asset_path("icons/subjects/#{root_subject.slug}.png")
      }
    end
    _subjects.sort_by(&:length).reverse
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

  def course_location
    return '' unless object.is_private?
    string = ""
    if object.teaches_at_home? and object.home_place
      string << "Au domicile de l'élève (rayon de #{object.home_place.radius}km autour de #{object.home_place.city.name})"
    end
    if object.teaches_at_home? and object.home_place and object.place
      string << " et "
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

  def details
    _details = []
    if on_appointment
      _details << { text: 'Pas de créneau précis, uniquement sur demande',
                    icon: ActionController::Base.helpers.asset_path("icons/icon-telephone.png") }
    end
    if teaches_at_home
      _details << { text: 'Cours à domicile',
                    icon: ActionController::Base.helpers.asset_path("icons/icon-house.png") }
    end
    if is_individual
      _details << { text: 'Cours individuel',
                    icon: ActionController::Base.helpers.asset_path("icons/icon-user.png") }
    else
      _details << { text: 'Cours collectif',
                    icon: ActionController::Base.helpers.asset_path("icons/icon-group.png") }
    end
    if is_lesson
      _details << { text: 'Cours régulier',
                    icon: ActionController::Base.helpers.asset_path("icons/icon-repeat.png") }
      _details << { text: "#{frequency} du #{start_date} au #{end_date}",
                  icon: ActionController::Base.helpers.asset_path("icons/icon-calendar.png") }
    end
    if cant_be_joined_during_year
      _details << { text: "Pas d'inscription en cours d'année",
                    icon: ActionController::Base.helpers.asset_path("icons/icon-forbidden.png") }
    else
      _details << { text: "Inscription tout au long de l'année",
                    icon: ActionController::Base.helpers.asset_path("icons/icon-repeat.png") }
    end
    if no_class_during_holidays
      _details << { text: "Pas de cours pendant les vacances scolaires",
                    icon: ActionController::Base.helpers.asset_path("icons/icon-forbidden.png") }
    end
    if is_private
      _details << { text: audiences,
                    icon: ActionController::Base.helpers.asset_path("icons/icon-group.png") }
      _details << { text: levels,
                    icon: ActionController::Base.helpers.asset_path("icons/icon-group.png") }
    end
    _details
  end

  def premium_prices
    if object.price_group
      object.price_group.prices.premium_prices
    else
      []
    end
  end

  def prices
    if object.price_group
      object.price_group.prices.non_premium_prices
    else
      []
    end
  end

  def prices_length
    if object.price_group
      object.price_group.prices.non_premium_prices.length
    else
      0
    end
  end

end
