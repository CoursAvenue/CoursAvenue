class CourseSerializer < ActiveModel::Serializer
  include CoursesHelper, PlanningsHelper, PricesHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :name, :description, :description_short, :db_type, :type, :subjects,
             :is_individual, :is_lesson, :frequency, :on_appointment,
             :course_location, :min_age_for_kid, :max_age_for_kid, :audiences,
             :levels, :details, :prices, :has_price_group,
             :is_open_for_trial, :has_promotion, :trial_courses_policy_popover, :min_price,
             :teaches_at_home, :accepts_payment

  has_one  :home_place,          serializer: PlaceSerializer
  has_one  :place,               serializer: PlaceSerializer
  has_many :plannings,           serializer: PlanningSerializer
  has_many :price_group_prices,  serializer: PriceSerializer
  has_many :prices,              serializer: PriceSerializer
  has_many :registrations,       serializer: PriceSerializer

  def home_place
    object.home_place if object.is_private?
  end

  def min_price
    PriceSerializer.new(object.prices.order('amount ASC').first) if object.prices.any?
  end

  def plannings
    (@options && @options[:plannings]) || object.plannings.visible.future.ordered_by_day
  end

  def description_short
    truncate(object.description, :length => 170, :separator => ' ') if object.description.present?
  end

  def is_individual
    object.is_individual?
  end

  def type
    object.type_name
  end

  def db_type
    object.type
  end

  def is_lesson
    object.is_lesson?
  end

  # TODO improve with subject_strings ?
  def subjects
    _subjects = []
    object.subjects.map(&:root).uniq.each do |root_subject|
      child_subjects = object.subjects.at_depth(2).order('name ASC').select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      _subjects << {
        root_name: root_subject.name,
        child_names: child_subjects.map(&:name).join(', '),
        icon: root_subject.slug,
        child_length: child_subjects.length
      }
    end
    _subjects.sort{ |a, b| b[:child_length] <=> a[:child_length] }
  end

  def frequency
    I18n.t(object.frequency) if object.frequency.present?
  end

  def course_location
    return '' unless object.is_private?
    readable_private_course_location(object)
  end

  def levels
    join_levels_text(object) if object.is_private?
  end

  def audiences
    join_audiences(object) if object.is_private?
  end

  def details
    _details = []
    if object.teaches_at_home?
      _details << { text: 'Se déplace à domicile',
                    icon: 'delta fa-house' }
    end
    if object.on_appointment?
      _details << { text: 'Pas de créneau précis, uniquement sur demande',
                    icon: 'delta fa-phone-o' }
    end
    if object.is_lesson?
      _details << { text: frequency,
                    icon: 'delta fa fa-calendar' }
    end
    if object.is_lesson? and object.cant_be_joined_during_year?
      _details << { text: "Pas d'inscription en cours d'année",
                    icon: 'delta fa-forbidden' }
    elsif object.is_lesson?
      _details << { text: "Inscriptions tout au long de l'année",
                    icon: 'delta fa-repeat' }
    end
    if object.no_class_during_holidays
      _details << { text: "Pas de cours pendant les vacances scolaires",
                    icon: 'delta fa-forbidden' }
    end
    if object.is_private? and object.on_appointment?
      _details << { text: join_audiences(object),
                    icon: 'gamma fa-audiences' }
      _details << { text: join_levels_text(object),
                    icon: 'delta fa-levels' }
    end
    _details
  end

  def registrations
    if object.price_group
      object.price_group.prices.registrations.order('amount ASC')
    else
      []
    end
  end

  def has_price_group
    object.price_group.present?
  end

  def trial_courses_policy_popover
    I18n.t("structures.trial_courses_policy.#{(object.structure.trial_courses_policy.blank? ? '1_trial' : object.structure.trial_courses_policy)}_nb_given")
  end

end
