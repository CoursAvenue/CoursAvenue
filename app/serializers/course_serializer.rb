class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper
  include PlanningsHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :description, :description_short, :type, :type_dash, :start_date, :end_date, :min_price_amount, :min_price_libelle, :data_url, :subjects,
             :has_free_trial_lesson, :event_type, :best_price, :is_individual, :search_term, :is_lesson, :frequency,
             :cant_be_joined_during_year, :no_class_during_holidays, :teaches_at_home, :teaches_at_home_radius,
             :has_premium_prices, :premium, :on_appointment, :course_location, :min_age_for_kid, :max_age_for_kid,
             :audiences, :levels, :details, :prices, :premium_prices, :prices_length, :promotion_title


  has_many :plannings,      serializer: PlanningSerializer
  has_many :prices,         serializer: PriceSerializer
  has_many :premium_prices, serializer: PriceSerializer

  def plannings
    @options[:plannings] || object.plannings.visible.future.ordered_by_day
  end

  def description_short
    truncate(object.description, :length => 170, :separator => ' ') if object.description
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

  def type_dash
    object.type_name.downcase.gsub(' ', '-')
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
        icon: ActionController::Base.helpers.asset_path("icons/subjects/#{root_subject.slug}.png"),
        child_length: child_subjects.length
      }
    end
    _subjects.sort{ |a, b| b[:child_length] <=> a[:child_length] }
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
      string << "<br>"
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

  def details
    _details = []
    if on_appointment
      _details << { text: 'Pas de créneau précis, uniquement sur demande',
                    icon: 'delta fa-phone-o' }
    end
    if teaches_at_home
      _details << { text: 'Cours à domicile',
                    icon: 'delta fa-house' }
    end
    if is_individual
      _details << { text: 'Cours particulier',
                    icon: 'delta fa-user' }
    else
      _details << { text: 'Cours collectif',
                    icon: 'fa-2x fa-group' }
    end
    if is_lesson
      _details << { text: "#{frequency} du #{start_date} au #{end_date}",
                    icon: 'delta fa-calendar' }
    end
    if cant_be_joined_during_year
      _details << { text: "Pas d'inscription en cours d'année",
                    icon: 'delta fa-forbidden' }
    else
      _details << { text: "Inscription tout au long de l'année",
                    icon: 'delta fa-repeat' }
    end
    if no_class_during_holidays
      _details << { text: "Pas de cours pendant les vacances scolaires",
                    icon: 'delta fa-forbidden' }
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
      object.price_group.prices.non_premium_prices.order('amount ASC')
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

  def promotion_title
    if object.structure.premium? and object.price_group
      if object.has_free_trial_lesson? and object.has_promotion?
        "Essai gratuit & promotions"
      elsif object.has_promotion?
        "Promotions"
      elsif object.has_free_trial_lesson?
        "Essai gratuit"
      end
    end
  end
end
