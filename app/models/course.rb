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
  has_many :reservations        , as: :reservable
  has_many :plannings           , dependent: :destroy
  has_many :teachers            , -> { uniq }, through: :plannings
  has_many :places              , -> { uniq }, through: :plannings
  has_many :prices              , dependent: :destroy
  has_many :reservation_loggers , dependent: :destroy

  has_and_belongs_to_many :subjects, -> { uniq }

  after_touch :reindex
  after_initialize :set_teaches_at_home

  # ------------------------------------------------------------------------------------ Scopes
  scope :active,                 -> { where(active: true) }
  scope :disabled,               -> { where(active: false) }
  scope :lessons,                -> { where(type: "Course::Lesson") }
  scope :workshops,              -> { where(type: "Course::Workshop") }
  scope :trainings,              -> { where(type: "Course::Training") }
  scope :workshops_and_training, -> { where{ type != "Course::Lesson" } }
  scope :open_courses,           -> { where(type: 'Course::Open') }

  default_scope                  -> { where{type != 'Course::Open'} }

  # ------------------------------------------------------------------------------------ Validations
  validates :type, :name  , presence: true
  validates :subjects     , presence: true

  attr_accessible :name, :type, :description,
                  :active,
                  :info,
                  :rating,
                  :is_promoted,
                  :price_details,
                  :has_online_payment,
                  :homepage_image,
                  :frequency,
                  :registration_date,
                  :is_individual, :is_for_handicaped,
                  :teaches_at_home,
                  :trial_lesson_info, # Info prix
                  :conditions,
                  :partner_rib_info,
                  :audition_mandatory,
                  :refund_condition,
                  :cant_be_joined_during_year,
                  :nb_participants,
                  :no_class_during_holidays,
                  :start_date, :end_date,
                  :subject_ids, :level_ids, :audience_ids, :place_id, :active,
                  :book_tickets_attributes, :prices_attributes, :registration_fees_attributes

  accepts_nested_attributes_for :prices,
                                 reject_if: :reject_price,
                                 allow_destroy: true

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
      when 'Course::Workshop'
        'workshop'
      end
    end

    latlon :location, multiple: true do
      self.locations.map do |location|
        Sunspot::Util::Coordinates.new(location.latitude, location.longitude)
      end
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

    double :rating
    integer :nb_comments do
      comments.count
    end

    boolean :active

    boolean :is_promoted
    boolean :has_online_payment
    boolean :has_promotion

    boolean :has_package_price
    boolean :has_trial_lesson
    boolean :has_unit_course_price

    integer :structure_id
  end

  handle_asynchronously :solr_index

  # Helper methods for prices

  def copy_prices_from!(course)
    new_prices = []
    course.prices.each do |price|
      new_prices << price.dup
    end
    self.prices        = new_prices
    self.price_details = course.price_details
    self.save
  end

  def book_tickets
    self.prices.select{|p| p.type == 'Price::BookTicket'}.sort_by(&:number)
  end

  def subscriptions
    self.prices.select{|p| p.type == 'Price::Subscription'}.sort{|p1, p2| Price::Subscription::TYPES_ORDER[p1.libelle] <=> Price::Subscription::TYPES_ORDER[p2.libelle] }
  end

  def registrations
    self.prices.select{|p| p.type == 'Price::Registration'}
  end

  def discounts
    self.prices.select{|p| p.type == 'Price::Discount'}
  end

  def trial
    self.prices.select{|p| p.type == 'Price::Trial'}.first
  end

  # Helper methods for place and locations
  def locations
    places.map(&:location).compact
  end

  def locations_around(latitude, longitude, radius=5)
    self.locations.reject do |location|
      Geocoder::Calculations.distance_between([latitude, longitude], [location.latitude, location.longitude], unit: :km) > radius
    end
  end

  def audiences
    self.plannings.map(&:audience_ids).flatten.uniq.map{ |audience_id| Audience.find(audience_id) }
  end

  def levels
    self.plannings.map(&:level_ids).flatten.uniq.map{ |level_id| Level.find(level_id) }
  end

  def has_promotion
    return has_promotion?
  end

  def has_promotion?
    return false if self.prices.empty?
    !(self.prices.order('promo_amount ASC').first.promo_amount).nil?
  end

  def has_package_price
    return prices.where{libelle.eq_any ['prices.subscription.annual', 'prices.subscription.semester', 'prices.subscription.trimester', 'prices.subscription.month']}.any?
  end

  def has_trial_lesson
    return self.prices.where{(type == 'Price::Trial')}.any?
  end

  def has_free_trial_lesson?
    return self.prices.where{(type == 'Price::Trial') & ((amount == nil) | (amount == 0))}.any?
  end

  def has_unit_course_price
    return (book_tickets.any? or prices.where(libelle: 'prices.individual_course').any?)
  end

  def min_price
    best_price.try(:promo_amount) || best_price.try(:amount)
  end

  def max_price
    prices.where{amount >= 0}.order('amount DESC').first.try(:amount)
  end

  # TODO: To be improved
  def similar_courses(limit = 5)
    parent_subject_ids = self.subjects.collect{|subject| subject.id}.uniq
    similar_courses   = Course.joins{subjects}.where{(active == true) & (subjects.id.eq_any parent_subject_ids)}.sample(limit) # With same parent subject
    if similar_courses.length < 5
      max_id          = Course.maximum('id')
      min_id          = Course.minimum('id')
      id_range        = max_id - min_id + 1
      random_id       = min_id + rand(id_range).to_i
      similar_courses = Course.limit(limit).offset(random_id)
    end
    similar_courses
  end

  def promotion_planning
    self.plannings.where{promotion != nil}.order('promotion ASC').first
  end

  def is_for_kid
    self.plannings.where{min_age_for_kid != nil}.length > 0
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

  def is_workshop?
    false
  end

  def is_lesson?
    false
  end

  def is_training?
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
    self.prices.where{(type != 'Price::Registration') & (amount > 0)}.order('promo_amount ASC, amount ASC').first
  end

  def most_expansive_price
    self.prices.where{(type != 'Price::Registration') & (amount > 0)}.order('amount DESC').first
  end

  def approximate_price_per_course
    one_class_price = prices.where{nb_courses == 1}
    if one_class_price.any?
      return one_class_price.first.amount
    else
      price = prices.where{amount != nil}.order('nb_courses DESC').first
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
    if (prices.any? and plannings.any?)
      self.active = true
      return self.save
    else
      errors.add(:prices, "Le cours n'a pas de tarifs")       if prices.empty?
      errors.add(:plannings, "Le cours n'a pas de plannings") if plannings.empty?
      return false
    end
  end

  def contact_email
    self.structure.contact_email
  end

  def duplicate!
    duplicate_course               = self.dup
    duplicate_course.name          += ' - copie'
    duplicate_course.subjects      = self.subjects
    duplicate_course.active        = false
    duplicate_course.slug          = nil
    duplicate_course.save
    duplicate_course.plannings     << self.plannings.map(&:dup)
    duplicate_course.prices        << self.prices.map(&:dup)
    duplicate_course.book_tickets  << self.book_tickets.map(&:dup)
    duplicate_course.save
    return duplicate_course
  end

  def should_generate_new_friendly_id?
    new_record? || !self.active
  end

  def migration_set_teaches_at_home
    self.update_column(:teaches_at_home, self.structure.teaches_at_home) if self.structure
  end

  private

  def set_teaches_at_home
    if self.new_record? and self.teaches_at_home.nil?
      self.teaches_at_home = self.structure.teaches_at_home if self.structure
    end
  end

  def reindex
    self.index
    self.plannings.map(&:index)
  end

  def reject_price attributes
    exists = attributes[:id].present?
    empty  = (attributes[:amount].blank? and attributes[:promo_percentage].blank?)
    attributes.merge!({:_destroy => 1}) if exists and empty
    return (!exists and empty)
  end


  def friendly_name
    [
      [-> { self.structure.name}, -> { self.type_name }, :name],
      [-> { self.type_name }, :name],
      :name
    ]
  end
end
