# encoding: utf-8
class Course < ActiveRecord::Base
  acts_as_paranoid

  include HasSubjects

  COURSE_FREQUENCIES = ['courses.frequencies.every_week',
                        'courses.frequencies.every_two_weeks',
                        'courses.frequencies.every_month']

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :place
  belongs_to :media

  # ------------------------------------------------------------------------------------ Model attributes and settings
  extend FriendlyId
  friendly_id :friendly_name, use: [:slugged, :finders]

  belongs_to :structure, touch: true
  belongs_to :price_group

  has_many :comments            , through: :structure
  has_many :participation_requests
  has_many :plannings           , dependent: :destroy
  has_many :teachers            , -> { uniq }, through: :plannings
  has_many :places              , -> { uniq }, through: :plannings
  has_many :prices
  has_many :price_group_prices,  through: :price_group, source: :prices
  has_many :indexable_cards,     dependent: :destroy

  has_and_belongs_to_many :subjects, -> { uniq }

  before_save :sanatize_description
  before_save :update_open_for_trial
  before_save :set_has_promotion
  before_save :update_structure_vertical_pages_breadcrumb

  after_save   :remove_price_if_no_trial

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :lessons,                     -> { where( type: "Course::Lesson" ) }
  scope :trainings,                   -> { where( type: "Course::Training" ) }
  scope :privates,                    -> { where( type: "Course::Private" ) }
  scope :regulars,                    -> { where(arel_table[:type].eq('Course::Private').or(arel_table[:type].eq('Course::Lesson')) ) }
  scope :collective,                  -> { where(arel_table[:type].eq('Course::Lesson').or(arel_table[:type].eq('Course::Training')) ) }
  scope :open_for_trial,              -> { where( is_open_for_trial: true ) }
  scope :not_open_for_trial,          -> { where( arel_table[:is_open_for_trial].eq(false).or(arel_table[:is_open_for_trial].eq(nil)) ) }

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :type, :name  , presence: true
  validates :subjects     , presence: true
  validates :prices       , presence: true, unless: -> (course) { course.no_trial? }
  validates :name, length: { maximum: 255 }

  attr_accessible :name, :type, :description,
                  :active, :info, :media_id, :no_trial,
                  :frequency, :is_individual,
                  :cant_be_joined_during_year,
                  :no_class_during_holidays,
                  :start_date, :end_date,
                  :subject_ids, :level_ids, :audience_ids, :place_id,
                  :price_group_id, :on_appointment,
                  :is_open_for_trial, :has_promotion, :prices_attributes,
                  :price_ids, :accepts_payment

  accepts_nested_attributes_for :prices,
                                 reject_if: :reject_price,
                                 allow_destroy: true

  def audiences
    self.plannings.map(&:audience_ids).flatten.uniq.map{ |audience_id| Audience.find(audience_id) }
  end

  def levels
    self.plannings.map(&:level_ids).flatten.uniq.map{ |level_id| Level.find(level_id) }
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

  def type_name
    'Cours'
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

  def can_be_published?
    plannings.any? and price_group.present?
  end

  def expired?
    false
  end

  #
  # Tell to the teacher wether the course is published
  # DO NOT USE IN FRONT END: because we lie to the teacher telling him that he
  # HAS to specify a price group but we still show it
  #
  # @return Boolean
  def is_published?
    return (!expired? and can_be_published?)
  end

  # Return the most used subject or the root subjects that has the most childs.
  #
  # @return Subject at depth 0
  def dominant_root_subject
    Rails.cache.fetch ["Course#dominant_root_subject/v1", self] do
      subjects.group_by(&:root).values.max_by(&:size).try(:first).try(:root)
    end
  end

  private

  # Set `has_promotion` attribute. Wether it has promotions or not.
  # A Promotion include Premium offsers AND Discounts
  #
  # @return nil
  def set_has_promotion
    if self.price_group_id_changed? or self.prices.any?(&:changed?)
      if (self.prices + self.price_group_prices).empty?
        self.has_promotion = false
      elsif (self.prices + self.price_group_prices).detect(&:promo_amount)
        self.has_promotion = true
      end
    end
    nil
  end

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

  # If the user sets the `open_for_trial` flag to true or false on the course itself,
  # we change all the plannings flag
  #
  # @return nil
  def update_open_for_trial
    if self.prices.detect(&:free?) and is_open_for_trial == false
      self.is_open_for_trial = true
    else
      self.is_open_for_trial = false
    end
    nil
  end

  # Method for accepts_nested_attributes_for :prices
  # Tells if the price is valid regarding attributes passed
  # Check if the price is valid by checking its valid? method
  # @param  attributes Automatically passed by Rails
  #
  # @return Boolean
  def reject_price attributes
    exists = attributes[:id].present?
    price_has_to_be_rejected  = attributes[:amount].blank? || attributes[:delete_price].present?
    # Destroy if price exists and amount is nil
    attributes.merge!({:_destroy => 1}) if exists and price_has_to_be_rejected
    # Reject if price does't not exist yet and amount is nil
    return (!exists and price_has_to_be_rejected)
  end

  def update_structure_vertical_pages_breadcrumb
    self.structure.delay.update_vertical_pages_breadcrumb
  end

  def remove_price_if_no_trial
    if no_trial
      prices.map(&:destroy)
    end
  end
end
