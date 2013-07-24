# encoding: utf-8
class Course < ActiveRecord::Base
  acts_as_paranoid

  include ActsAsCommentable
  include HasSubjects

  COURSE_FREQUENCIES = ['courses.frequencies.every_week', 'courses.frequencies.every_two_weeks', 'courses.frequencies.every_month']

  # ------------------------------------------------------------------------------------ Model attributes and settings
  extend FriendlyId
  friendly_id :friendly_name, use: :slugged

  has_attached_file :homepage_image,
                    :styles => {default: '1600×500#'},
                    :path => "course/:id/homepage_image/:fingerprint-:style.:extension"

  if Rails.env.production?
    has_attached_file :image,
                      :styles => { wide: "800x480#", thumb: "200x200#", mini: '50x50#' },
                      :path => "course/:id/image/:fingerprint-:style.:extension"
  else
    has_attached_file :image,
                      :styles => { wide: "800x480#", thumb: "200x200#", mini: '50x50#' }
  end

  belongs_to :structure, touch: true
  belongs_to :place,     touch: true
  has_one    :city,      through: :place

  has_and_belongs_to_many :users


  has_many :comments,             as: :commentable
  has_many :reservations,         as: :reservable
  has_many :plannings           , dependent: :destroy, conditions: "plannings.end_date > '#{Date.today}'"
  has_many :teachers            , through: :plannings
  has_many :prices              , dependent: :destroy
  has_many :book_tickets        , dependent: :destroy
  has_many :registration_fees   , dependent: :destroy
  has_many :reservation_loggers , dependent: :destroy

  has_and_belongs_to_many :subjects, :uniq => true

  # ------------------------------------------------------------------------------------ Scopes
  scope :active, where(active: true)

  # ------------------------------------------------------------------------------------ Validations
  validates :type, :name  , presence: true
  validates :place        , presence: true
  validates :subjects     , presence: true

  before_save :set_structure_if_empty
  before_save :replace_slash_n_r_by_brs

  attr_reader :delete_image

  attr_accessible :name, :type, :description,
                  :active,
                  :info,
                  :rating,
                  :is_promoted,

                  :has_online_payment,
                  :homepage_image,
                  :image,
                  :frequency,
                  :registration_date,
                  :is_individual, :is_for_handicaped,
                  :trial_lesson_info, # Info prix
                  :price_details, :price_info,
                  :conditions,
                  :partner_rib_info,
                  :audition_mandatory,
                  :refund_condition,
                  :can_be_joined_during_year,
                  :nb_participants,
                  :start_date, :end_date,
                  :subject_ids, :level_ids, :audience_ids, :room_id, :place_id, :active,
                  :book_tickets_attributes, :prices_attributes, :registration_fees_attributes

  accepts_nested_attributes_for :prices,
                                 reject_if: :reject_price,
                                 allow_destroy: true

  accepts_nested_attributes_for :book_tickets,
                                 reject_if: :reject_price,
                                 allow_destroy: true

  accepts_nested_attributes_for :registration_fees,
                                 reject_if: :reject_price,
                                 allow_destroy: true

  # ------------------------------------------------------------------------------------ Search attributes
  searchable do
    text :name, :boost => 2
    text :place_name do
      place.long_name
    end

    text :place_info do
      place.gmaps4rails_address
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
        subject_array << subject.parent
      end
      subject_array.uniq.map(&:name)
    end

    integer :subject_ids, multiple: true do
      subject_ids = []
      subjects.each do |subject|
        subject_ids << subject.id
        subject_ids << subject.parent.id
      end
      subject_ids.uniq
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      subjects.each do |subject|
        subject_slugs << subject.slug
        if subject.parent
          subject_slugs << subject.parent.slug
        end
        if subject.parent and subject.parent.parent
          subject_slugs << subject.parent.parent.slug
        end
      end
      subject_slugs.uniq
    end

    string  :type do
      case type
      when 'Course::Lesson'
        'lesson'
      when 'Course::Training'
        'training'
      when 'Course::Workshop'
        'workshop'
      end
    end

    latlon :location do
      Sunspot::Util::Coordinates.new(place.latitude, place.longitude)
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

    string :time_slots, multiple: true

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

    integer :zip_code do
      place.zip_code
    end

    integer :min_price
    integer :max_price
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
  end

  handle_asynchronously :solr_index

  def audiences
    self.plannings.map(&:audience_ids).flatten.uniq.map{ |audience_id| Audience.find(audience_id) }
  end

  def levels
    self.plannings.map(&:level_ids).flatten.uniq.map{ |level_id| Level.find(level_id) }
  end

  def recent_plannings
    self.plannings.where{start_date > Date.today}
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
    return prices.where(libelle: 'prices.trial_lesson').any?
  end

  def has_unit_course_price
    return (book_tickets.any? or prices.where(libelle: 'prices.individual_course').any?)
  end

  def min_price
    best_price.try(:promo_amount) || best_price.try(:amount)
  end

  def max_price
    prices.where{amount >= 0}.order('promo_amount DESC, amount DESC').first.try(:amount)
  end

  def time_slots
    time_slots = []
    plannings.each do |planning|
      if planning.start_time and planning.end_time
        CoursAvenue::Application::TIME_SLOTS.each do |time_slot_name, time_slot|
          if (planning.start_time >= TimeParser.parse_time_string(time_slot[:start_time])) & (planning.start_time <= TimeParser.parse_time_string(time_slot[:end_time]))
            time_slots << time_slot_name.to_s
          end
        end
      end
    end
    time_slots.uniq
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

  def best_price
    self.prices.where{amount >= 0}.order('promo_amount ASC, amount ASC').first
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

  def description_for_input
    self.description.gsub(/<br>/, '&#x000A;').html_safe if self.description
  end

  def description_for_meta
    self.description.gsub(/<br>/, ' ').html_safe if self.description
  end

  def activate!
    if (prices.any? or book_tickets.any?)
      self.active = true
      return self.save
    else
      errors.add(:prices, "Le cours n'a pas de tarif")       if prices.empty? and book_tickets.empty?
      return false
    end
  end

  def contact_email
    self.place.contact_email
  end

  def duplicate!
    course_duplicate               = self.dup
    course_duplicate.name          += ' - copie'
    course_duplicate.subjects      = self.subjects
    course_duplicate.active        = false
    course_duplicate.slug          = nil
    course_duplicate.save
    course_duplicate.plannings     << self.plannings.map(&:dup)
    course_duplicate.prices        << self.prices.map(&:dup)
    course_duplicate.book_tickets  << self.book_tickets.map(&:dup)
    course_duplicate.save
    return course_duplicate
  end

  def should_generate_new_friendly_id?
    new_record? || !self.active
  end

  private

  def reject_price attributes
    exists = attributes[:id].present?
    empty  = attributes[:amount].blank?
    attributes.merge!({:_destroy => 1}) if exists and empty
    return (!exists and empty)
  end


  def friendly_name
    slugs = [self.type_name, self.name]
    slugs << self.city.name      if self.city
    slugs << self.structure.name if self.structure
    return slugs
  end

  def set_structure_if_empty
    if structure.nil? and place.present?
      self.structure_id = place.structure_id
    end
  end

  def replace_slash_n_r_by_brs
    self.description = self.description.gsub(/\r\n/, '<br>') if self.description
  end

end
