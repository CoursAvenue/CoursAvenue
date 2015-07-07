class Structure::CourseCreationForm
  include ActiveModel::Model
  include Virtus.model

  attr_reader :structure
  attr_reader :course
  attr_reader :place
  attr_reader :planning

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

  attribute :place_street, String

  attribute :place_zip_code, String
  validates :place_zip_code, presence: true

  attribute :place_city_id, Integer
  validates :place_city_id, presence: true

  attribute :place_latitude, Float
  attribute :place_longitude, Float

  attribute :place_radius, Integer

  attribute :level_ids, Array[Integer]
  validates :level_ids, presence: true

  attribute :audience_ids, Array[Integer]
  validates :audience_ids, presence: true

  attribute :min_age_for_kid, Integer
  attribute :max_age_for_kid, Integer

  attribute :planning_week_day, Integer
  attribute :planning_start_time, Time
  attribute :planning_end_time, Time
  attribute :planning_duration, Time

  attribute :planning_start_date
  attribute :planning_end_date

  attribute :teaches_at_home, Boolean
  attribute :teaches_at_place, Boolean

  # "Save" the Course Creation form.
  # We don't really save the object, but persist the attributes of the object in the related Models,
  # here the Course and Price models.
  #
  # @return Boolean, whether the object has been "saved".
  def save
    @structure = Structure.find(@structure_id)
    sanitize_attributes!

    valid? ? persist! : false
  end

  # The audiences selected on the Form.
  #
  # @return Array of Audiences
  def audiences
    return [] if @audience_ids.nil?
    @audience_ids.map { |id| Audience.find(id) }
  end

  def set_dates_and_times(options)
    # Setting time
    if options['planning_start_time(4i)'].present? and options['planning_start_time(5i)'].present?
      @planning_start_time = TimeParser.parse_time_string(
        "#{options['planning_start_time(4i)']}h#{options['planning_start_time(5i)']}")
    end

    if options['planning_end_time(4i)'].present? and options['planning_end_time(5i)'].present?
      @planning_end_time = TimeParser.parse_time_string(
        "#{options['planning_end_time(4i)']}h#{options['planning_end_time(5i)']}")
    end

    if @planning_end_time.blank? and @planning_duration.present?
      @planning_end_time = @planning_start_time + @planning_duration.to_i.minutes
    elsif @planning_end_time.present? and  @planning_duration.blank?
      @planning_duration = TimeParser.duration_from @planning_start_time, @planning_end_time
    end
  end

  private

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
      place_id: @place.id,
    )

    if !@course.persisted?
      errors[:course] = @course.errors.messages
      return false
    end

    @course_prices.each { |price| price.course_id = course.id }

    @planning = @course.plannings.create(
      start_time: @planning_start_time,
      end_time: @planning_end_time,
      week_day: @planning_week_day,
      duration: @planning_duration,
      min_age_for_kid: @min_age_for_kid,
      max_age_for_kid: @max_age_for_kid,
      audience_ids: @audience_ids.join(','),
      level_ids: @level_ids.join(','),
      place_id: @place.id
    )

    if !@planning.persisted?
      errors[:planning] = @planning.errors.messages
      return false
    end

    true
  end

  # Sanitize the Prices Attributes, meaning that we wrap them into an array if the attributes are
  # not already in an array.
  #
  # @return the sanitize attributes
  def sanitize_attributes!
    remove_invalid_subjects!
    remove_invalid_audiences!
    remove_invalid_levels!
    set_prices!
    nil
  end

  def remove_invalid_subjects!
    @course_subject_ids.select! do |subject|
      Subject.where(id: subject.to_i).any?
    end
  end

  def remove_invalid_audiences!
    @audience_ids.select! do |audience|
      Audience.where(id: audience.to_i).any?
    end
  end

  def remove_invalid_levels!
    @level_ids.select! do |level|
      Level.where(id: level.to_i).any?
    end
  end

  # Store the prices attributes as an Array.
  # This allows us to manually create the Prices by just looping on the attribute array.
  #
  # @return the Array of Prices.
  def set_prices!
    return if @course_prices_attributes.nil?
    if @course_prices_attributes.keys.include?('0')
      @course_prices_attributes = @course_prices_attributes.map { |_, v| v }
      @course_prices_attributes.reject! { |p| p["amount"].blank? or p["amount"].nil? }
    else
      @course_prices_attributes = [@course_prices_attributes].flatten.compact
    end
  end
end
