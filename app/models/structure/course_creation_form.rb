class Structure::CourseCreationForm
  include ActiveModel::Model
  include Virtus.model

  attr_reader :structure
  attr_reader :course
  attr_reader :place

  attr_accessor :course_prices
  attr_accessor :course_prices_attributes

  attribute :structure_id, String
  validates :structure_id, presence: true

  # Course attributes
  attribute :course_name, String
  validates :course_name, presence: true

  attribute :course_type, String
  validates :course_type, presence: true

  attribute :course_subject_ids, Array[Integer]
  validates :course_subject_ids, presence: true

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
    @structure = Structure.find(@structure_id)
    remove_invalid_subjects!
    sanitize_prices_attributes!

    valid? ? persist! : false
  end

  private

  # TODO: Set errors.
  def persist!
    @course_subject_ids = @course_subject_ids.map(&:to_i)

    @place = @structure.places.create(
      name: @place_name,
      street: @place_street,
      zip_code: @place_zip_code,
      city_id: @place_city_id,
      latitude: @place_latitude,
      longitude: @place_longitude
    )

    if !@place.persisted?
      errors[:place] = @place.errors.messages
      return false
    end

    @course_prices = @course_prices_attributes.map do |attributes|
      Price.create(attributes)
    end

    @course = @structure.courses.create(
      type: @course_type,
      name: @course_name,
      subject_ids: @course_subject_ids,
      price_ids: @course_prices.map(&:id),
      place_id: @place.id
    )

    if !@course.persisted?
      errors[:course] = @course.errors.messages
      return false
    end

    true
  end

  # Removes the invalid subjects from the association array.
  #
  # @return The new array.
  def remove_invalid_subjects!
    @course_subject_ids.select! do |subject|
      Subject.where(id: subject.to_i).any?
    end
  end

  # Sanitize the Prices Attributes, meaning that we wrap them into an array if the attributes are
  # not already in an array.
  #
  # @return the sanitize attributes
  def sanitize_prices_attributes!
    @course_prices_attributes = [@course_prices_attributes].flatten.compact
  end
end
