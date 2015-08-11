class StructureShowSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  # cached
  # delegate :cache_key, to: :object

  attributes :id, :name, :slug, :description, :description_short, :trial_courses_policy,
             :logo_thumb_url, :courses_without_open_for_trials,
             :trainings_without_open_for_trials, :courses_open_for_trial,
             :about, :about_bis, :about_genre,
             :audience, :gives_group_courses,
             :gives_individual_courses, :structure_type, :given_course_types,
             :given_funding_type, :places_count, :subjects, :has_teachers, :has_only_one_more_info,
             :phone_numbers, :is_sleeping, :website, :cities_text, :contact_email, :can_receive_payments,
             :dominant_root_subject_slug

  has_many :places                            , serializer: PlaceSerializer
  has_many :courses_open_for_trial            , serializer: ShortCourseSerializer
  has_many :courses_without_open_for_trials   , serializer: ShortCourseSerializer
  has_many :trainings_without_open_for_trials , serializer: ShortCourseSerializer

  def courses_open_for_trial
    object.courses.open_for_trial
  end

  def courses_without_open_for_trials
    object.courses.regulars.not_open_for_trial
  end

  def trainings_without_open_for_trials
    object.courses.trainings.not_open_for_trial
  end

  def places_count
    object.places.count
  end

  def places
    if @options and @options[:place_ids].present?
      place_ids = @options[:place_ids]
      object.places.where( Place.arel_table[:id].eq_any(place_ids) )
    else
      object.places
    end
  end

  def description_short
    truncate(object.description.gsub(/\r\n\r\n/, ' '), length: 340, separator: ' ') if object.description
  end

  def structure_type
    case object.structure_type
    when 'structures.association'
      "Association"
    when 'structures.company'
      "École"
    when 'structures.independant'
      "Professeur indépendant"
    end
  end

  def about
    I18n.t("structures.structure_type_contact.#{(object.structure_type.present? ? object.structure_type : 'structures.other')}")
  end

  def about_bis
    I18n.t("structures.structure_type_contact_bis.#{(object.structure_type.present? ? object.structure_type : 'structures.other')}")
  end

  def about_genre
    I18n.t("structures.structure_type_genre.#{(object.structure_type.present? ? object.structure_type : 'structures.other')}")
  end

  def audience
    object.audiences.sort_by(&:order).map{|audience| I18n.t(audience.name)}.join(', ')
  end

  def logo_thumb_url
    object.logo.url(:thumb) if object.logo.present?
  end

  def given_course_types
    types = []
    if object.gives_individual_courses
      types << 'Cours individuels'
    end
    if object.teaches_at_home and object.places.homes.any?
      if object.places.homes.first.radius.present?
        types << "Cours individuels à domicile (#{object.places.homes.first.city.name.capitalize} dans un rayon de #{object.places.homes.first.radius}km)"
      else
        types << "Cours individuels à domicile"
      end
    end
    if object.gives_group_courses
      types << 'Cours collectifs'
    end
    types.join('. ')
  end

  def given_funding_type
    object.funding_types.map{ |funding_type| I18n.t(funding_type.name)}.join(', ')
  end

  # TODO improve with subject_strings ?
  def subjects
    _subjects = []
    object.subjects.at_depth(0).uniq.each do |root_subject|
      child_subjects = object.subjects.at_depth(2).uniq.order('name ASC').select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      _subjects << {
        root_name: root_subject.name,
        child_names: child_subjects.map(&:name).join(', '),
        icon: root_subject.slug
      }
    end
    _subjects.sort_by(&:length).reverse
  end

  def has_teachers
    object.teachers.count > 0
  end

  def has_only_one_more_info
    return (object.funding_types.empty? and object.audiences.empty? and object.structure_type.nil?)
  end

  def phone_numbers
    object.phone_numbers.map{ |phone_number| readable_phone_number(phone_number.number) }.uniq
  end

  def trial_courses_policy
    I18n.t("structures.trial_courses_policy.#{object.trial_courses_policy || 1}_nb")
  end

  def contact_email
    object.contact_email
  end

  def can_receive_payments
    object.can_receive_payments?
  end

  def is_sleeping
    object.is_sleeping || !object.enabled?
  end

  def dominant_root_subject_slug
    object.dominant_root_subject.try(:slug)
  end
end
