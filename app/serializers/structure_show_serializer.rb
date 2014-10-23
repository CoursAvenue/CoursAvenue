class StructureShowSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :name, :slug, :description, :description_short,
             :logo_thumb_url, :courses, :trainings,
             :has_courses, :about, :about_bis, :about_genre,
             :audience, :gives_group_courses,
             :gives_individual_courses, :structure_type, :given_course_types,
             :given_funding_type, :places_count, :comments, :subjects, :has_teachers, :has_only_one_more_info,
             :phone_numbers, :is_sleeping, :website, :premium, :has_trial_courses

  has_many :comments, serializer: CommentSerializer
  has_many :places  , serializer: PlaceSerializer
  has_many :teachers, serializer: TeacherSerializer

  def comments
    object.comments.accepted.limit(5)
  end

  def courses
    (object.courses.lessons.select(&:is_published?) + object.courses.privates.select(&:is_published?)).map do |course|
      CourseSerializer.new(course, structure: object)
    end
  end

  def trainings
    object.courses.trainings.select(&:is_published?).map do |course|
      CourseSerializer.new(course, structure: object)
    end
  end

  def places_count
    object.places.count
  end

  def places
    if @options[:place_ids].present?
      place_ids = @options[:place_ids]
      object.places.where( Place.arel_table[:id].eq_any(place_ids) )
    else
      object.places
    end
  end

  def description_short
    truncate(object.description, length: 500, separator: ' ') if object.description
  end

  def structure_type
    case object.structure_type
    when 'structures.association'
      "Association"
    when 'structures.company'
      "École"
    when 'structures.independant'
      "Professeur"
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

  def has_courses
    object.courses.count > 0
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
        icon: "https://coursavenue-public.s3.amazonaws.com/public_assets/icons/subjects/#{root_subject.slug}.png"
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

  def has_trial_courses
    object.has_trial_courses?
  end
end
