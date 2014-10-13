# encoding: utf-8
class Course < ActiveRecord::Base
  acts_as_paranoid

  include HasSubjects

  COURSE_FREQUENCIES = ['courses.frequencies.every_week', 'courses.frequencies.every_two_weeks', 'courses.frequencies.every_month']

  # ------------------------------------------------------------------------------------ Model attributes and settings
  extend FriendlyId
  friendly_id :friendly_name, use: [:slugged, :finders]

  belongs_to :structure, touch: true

  has_many :comments            , through: :structure
  has_many :participations      , through: :plannings
  has_many :reservations        , as: :reservable
  has_many :plannings           , dependent: :destroy
  has_many :teachers            , -> { uniq }, through: :plannings
  has_many :places              , -> { uniq }, through: :plannings
  belongs_to :price_group
  has_many :prices              , through: :price_group
  has_many :reservation_loggers , dependent: :destroy

  has_and_belongs_to_many :subjects, -> { uniq }

  before_save :sanatize_description
  after_save  :update_plannings_dates_if_needs_to
  after_save  :reindex_plannings unless Rails.env.test?
  after_save  :update_plannings_available_in_discovery_pass

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :active,                      -> { where( active: true ) }
  scope :disabled,                    -> { where( active: false ) }
  scope :lessons,                     -> { where( type: "Course::Lesson" ) }
  scope :trainings,                   -> { where( type: "Course::Training" ) }
  scope :privates,                    -> { where( type: "Course::Private" ) }
  scope :regulars,                    -> { where(arel_table[:type].eq('Course::Private').or(arel_table[:type].eq('Course::Lesson')) ) }
  scope :without_open_courses,        -> { where.not( type: 'Course::Open' ) }
  scope :open_courses,                -> { where( type: 'Course::Open' ) }
  scope :available_in_discovery_pass, -> { where.not( available_in_discovery_pass: nil ) }

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :type, :name  , presence: true
  validates :subjects     , presence: true
  validates :name, length: { maximum: 255 }

  attr_accessible :name, :type, :description,
                  :active, :info, :is_promoted,
                  :frequency, :is_individual,
                  :cant_be_joined_during_year,
                  :nb_participants,
                  :no_class_during_holidays,
                  :start_date, :end_date,
                  :subject_ids, :level_ids, :audience_ids, :place_id,
                  :price_group_id, :on_appointment,
                  :available_in_discovery_pass

  # ------------------------------------------------------------------------------------ Search attributes
  searchable do
    text :name, :boost => 2

    text :structure_name do
      self.structure.name if self.structure
    end

    text :planning_info do
      plannings.map(&:info)
    end

    text :teachers do
      plannings.collect{|p| p.teacher.try(:name)}.compact.uniq
    end

    text :subjects do
      subject_array = []
      subjects.each do |subject|
        subject_array << subject
        subject_array << subject.parent if subject.parent
      end
      subject_array.uniq.map(&:name)
    end

    integer :subject_ids, multiple: true do
      subject_ids = []
      subjects.each do |subject|
        subject_ids << subject.id
        subject_ids << subject.parent.id if subject.parent
      end
      subject_ids.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      subjects.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.parent.slug if subject.parent
        if subject.grand_parent
          subject_slugs << subject.grand_parent.slug
        end
      end
      subject_slugs.uniq
    end

    string :type do
      case type
      when 'Course::Lesson'
        'lesson'
      when 'Course::Training'
        'training'
      end
    end

    latlon :location, multiple: true do
      self.places.map do |place|
        Sunspot::Util::Coordinates.new(place.latitude, place.longitude)
      end
    end

    string :zip_codes, multiple: true do
      self.places.uniq.map(&:zip_code)
    end

    integer :audience_ids, multiple: true do
      self.audiences.map(&:id)
    end

    integer :level_ids, multiple: true do
      self.levels.map(&:id)
    end

    string :week_days, multiple: true do
      plannings.map(&:week_day).uniq.compact
    end

    integer :min_age_for_kid, multiple: true do
      plannings.map(&:min_age_for_kid).uniq.compact
    end
    integer :max_age_for_kid, multiple: true do
      plannings.map(&:max_age_for_kid).uniq.compact
    end

    time :start_time, multiple: true do
      plannings.map(&:start_time).uniq.compact
    end
    time :end_time, multiple: true do
      plannings.map(&:end_time).uniq.compact
    end

    boolean :available_in_discovery_pass

    boolean :has_description do
      self.description.present?
    end

    boolean :has_comment do
      comments.count > 0
    end

    date :start_date, multiple: true do
      plannings.map(&:start_date).uniq.compact
    end

    date :end_date, multiple: true do
      plannings.map(&:end_date).uniq.compact
    end

    integer :min_price
    integer :max_price

    boolean :has_free_trial_lesson do
      self.has_free_trial_lesson?
    end

    boolean :has_admin do
      self.structure.admins.any? if self.structure
    end

    double :approximate_price_per_course

    integer :nb_comments do
      comments.count
    end

    boolean :active

    boolean :is_promoted
    boolean :has_promotion

    boolean :has_package_price
    boolean :has_trial_lesson
    boolean :has_unit_course_price

    integer :structure_id
  end

  handle_asynchronously :solr_index unless Rails.env.test?

  def audiences
    self.plannings.map(&:audience_ids).flatten.uniq.map{ |audience_id| Audience.find(audience_id) }
  end

  def levels
    self.plannings.map(&:level_ids).flatten.uniq.map{ |level_id| Level.find(level_id) }
  end

  def has_promotion
    return has_promotion?
  end

  # Wether it has promotions or not. A Promotion include Premium offsers AND Discounts
  #
  # @return Boolean
  def has_promotion?
    return false if self.prices.empty?
    !(self.prices.order('promo_amount ASC NULLS LAST').first.promo_amount).nil?
  end

  def has_package_price
    return prices.where( Price.arel_table[:libelle].eq_any(['prices.subscription.annual', 'prices.subscription.semester', 'prices.subscription.trimester', 'prices.subscription.month']) ).any?
  end

  def has_trial_lesson
    return self.prices.where( type: 'Price::Trial' ).any?
  end

  # Wether it has free trial course or not
  #
  # @return Boolean
  def has_free_trial_lesson?
    return self.prices.where( Price.arel_table[:type].eq('Price::Trial').and(
                              (Price.arel_table[:amount].eq(nil).or(Price.arel_table[:amount].eq(0)))) ).any?
  end

  def has_unit_course_price
    return false if price_group.nil?
    return (price_group.book_tickets.any? or prices.where(libelle: 'prices.individual_course').any?)
  end

  def min_price
    best_price.try(:promo_amount) || best_price.try(:amount)
  end

  def max_price
    prices.where( Price.arel_table[:amount].gteq(0) ).order('amount DESC').first.try(:amount)
  end

  def promotion_planning
    self.plannings.where.not( promotion: nil ).order('promotion ASC').first
  end

  def is_for_kid
    self.plannings.where.not( min_age_for_kid: nil ).length > 0
  end

  def has_multiple_teacher?
    self.plannings.map(&:teacher_id).uniq.compact.length > 1
  end

  def has_teacher?
    self.plannings.map(&:teacher_id).uniq.compact.length > 0
  end

  def promotion
    self.plannings.order('promotion ASC').first.promotion
  end

  def promotion_price
    new_price = best_price.amount + (best_price.amount * (promotion / 100))
    ('%.2f' % new_price).gsub('.', ',').gsub(',00', '')
  end

  def is_lesson?
    false
  end

  def is_training?
    false
  end

  def is_private?
    false
  end

  def is_open?
    false
  end

  # Returns an array with one or two values
  def price_range
    if best_price == most_expansive_price
      [best_price]
    else
      [best_price, most_expansive_price]
    end
  end

  def best_price
    self.prices.where( Price.arel_table[:type].not_eq('Price::Registration').and(
                       Price.arel_table[:amount].gt(0)) ).order('COALESCE(promo_amount, amount) ASC').first
  end

  def most_expansive_price
    self.prices.where( Price.arel_table[:type].not_eq('Price::Registration').and(
                       Price.arel_table[:amount].gt(0)) ).order('amount DESC').first
  end

  def approximate_price_per_course
    one_class_price = prices.where( nb_courses: 1 )
    if one_class_price.any?
      return one_class_price.first.amount
    else
      price = prices.where.not( amount: nil ).order('nb_courses DESC').first
      if price and price.amount and price.nb_courses
        return price.amount / price.nb_courses
      else
        return 0
      end
    end
  end

  def type_name
    'Cours'
  end

  def description_for_meta
    self.description.gsub(/\r\n\r\n/, ' ').html_safe if self.description
  end

  def activate!
    if price_group and plannings.any?
      self.active = true
      return save
    else
      errors.add(:price_group, "Le cours n'a pas de tarifs")    unless price_group
      errors.add(:plannings,   "Le cours n'a pas de plannings") if plannings.empty?
      return false
    end
  end

  def contact_email
    self.structure.contact_email
  end

  def should_generate_new_friendly_id?
    new_record? || false
  end

  def other_event_type?
    false
  end

  def has_premium_prices?
    return false if price_group.nil?
    price_group.has_premium_prices?
  end

  def can_be_published?
    plannings.future.any? and price_group.present?
  end

  def expired?
    false
  end

  def is_published?
    return (!expired? and can_be_published?)
  end

  private

  # Attributes used to create the slug for Friendly ID
  #
  # @return Array
  def friendly_name
    [
      [-> { self.structure.name}, -> { self.type_name }, :name],
      [-> { self.type_name }, :name],
      :name
    ]
  end

  # Remove unwanted character from the content
  #
  # @return nil
  def sanatize_description
    self.description = StringHelper.sanatize(self.description) if self.description.present?
    nil
  end


  # If start or end_date has changed AND it is a lesson, then
  # plannings dates should be updated
  #
  # @return nil
  def update_plannings_dates_if_needs_to
    if self.is_lesson? and (self.start_date_changed? or self.end_date_changed?)
      self.plannings.each do |planning|
        planning.start_date = self.start_date if self.start_date_changed?
        planning.end_date   = self.end_date if self.end_date_changed?
        planning.save
      end
    end
    nil
  end

  def reindex_plannings
    self.plannings.map{ |p| p.delay.index }
  end

  # If the user sets the `available_in_discovery_pass` flag to true or false on the course itself,
  # we change all the plannings flag
  #
  # @return nil
  def update_plannings_available_in_discovery_pass
    if self.available_in_discovery_pass_changed?
      self.plannings.each do |planning|
        planning.update_column :available_in_discovery_pass, self.available_in_discovery_pass
      end
      self.plannings.map{ |p| p.delay.index }
    end
    nil
  end
end
