class Structure::CourseCreationForm
  include ActiveModel::Model
  include Virtus.model

  attr_reader :structure
  attr_reader :course
  attr_reader :place

  attr_accessor :prices_attributes

  attribute :structure_slug, String
  validates :structure_slug, presence: true

  # Course attributes
  attribute :course_name, String
  validates :course_name, presence: true

  attribute :course_type, String
  validates :course_type, presence: true

  attribute :course_subject_ids, Array[Integer]
  validates :course_subject_ids, presence: true

  attribute :course_prices, Array[Price]
  validates :course_prices, presence: true

  attribute :course_frequency, String

  attribute :course_cant_be_joined_during_year, Boolean
  attribute :course_no_class_during_holidays, Boolean

  # Place attributes
  attribute :place_name, String
  validates :place_name, presence: true

  attribute :place_street, String
  validates :place_street, presence: true

  attribute :place_zip_code, String
  validates :place_zip_code, presence: true

  attribute :place_city_id, Integer
  validates :place_city_id, presence: true

  attribute :place_latitude, Float

  attribute :place_longitude, Float

  # "Save" the Course Creation form.
  # We don't really save the object, but persist the attributes of the object in the related Models,
  # here the Course and Price models.
  #
  # @return Boolean, whether the object has been "saved".
  def save
    @structure = Structure.find(@structure_slug)
    valid? ? persist! : false
  end

  private

  def persist!
    @course_subject_ids = @course_subject_ids.map(&:to_i)

    @place = @structure.places.create(
      name: @place_name,
      street: @place_street,
      zip_code: @place_zip_code,
      city_id: @place_city_id
    )
    return false if @place.persisted?

    @course = @structure.courses.build(
      type: @course_type,
      name: @course_name,
      subjects_ids: @course_subject_ids,
      prices_attributes: @course_prices,
      place_id: @place.id
    )
    return false if @course.persisted?

    true
  end
end
