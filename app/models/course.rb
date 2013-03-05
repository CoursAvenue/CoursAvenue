# encoding: utf-8
# Courses are grouped by same name, audiences and levels
class Course < ActiveRecord::Base

  # ------------------------------------------------------------------------------------ Model attributes and settings
  extend FriendlyId
  friendly_id :friendly_name, use: [:slugged, :history]

  # before_save :enhance_slug

  has_attached_file :homepage_image, :styles => {default: '1600×500#'}
  has_attached_file :image, :styles => { wide: "800x480#", thumb: "200x200#" }

  belongs_to :structure
  belongs_to :place
  has_one    :city  , through: :place

  has_many :plannings
  has_many :prices           , dependent: :destroy
  has_many :book_tickets     , dependent: :destroy
  has_many :registration_fees, dependent: :destroy

  has_and_belongs_to_many :audiences
  has_and_belongs_to_many :levels

  has_and_belongs_to_many :subjects, :uniq => true

  # ------------------------------------------------------------------------------------ Validations
  validates :structure  , presence: true
  # validates :subjects, presence: true


  attr_accessible :name,
                  :has_online_payment,
                  :homepage_image,
                  :frequency,
                  :is_promoted,
                  :description,
                  :info,
                  :registration_date,
                  :is_individual,
                  :is_for_handicaped,
                  :trial_lesson_info, # Info prix
                  :price_details,
                  :price_info,
                  :conditions,
                  :partner_rib_info,
                  :audition_mandatory,
                  :refund_condition,
                  :can_be_joined_during_year,
                  :subject_ids
  # ------------------------------------------------------------------------------------ Search methods
  searchable do
    text :name, :boost => 2
    text :structure_name do
      structure.name
    end

    text :place_info do
      place.gmaps4rails_address
    end

    text :planning_info do
      plannings.map(&:info)
    end

    text :teachers do
      plannings.map(&:teacher_name).uniq.compact
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

    string :city do
      place.city.slug
    end

    integer :audience_ids, multiple: true
    integer :level_ids   , multiple: true

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

    # latlon(:location) do
    #   Sunspot::Util::Coordinates.new(place.latitude, place.longitude)
    # end

    boolean :is_promoted
    boolean :has_online_payment
    boolean :has_promotion

    boolean :has_no_price

    boolean :has_package_price
    boolean :has_trial_lesson
    boolean :has_unit_course_price
  end

  def has_promotion
    plannings.order('promotion ASC').first.promotion != nil
  end

  def has_no_price
    prices.order('amount DESC').first.amount == nil
  end

  def has_package_price
    return prices.where{libelle.eq_any ['prices.annual', 'prices.semester', 'prices.trimester', 'prices.month', 'prices.two_lesson_per_week_package']}.any?
  end

  def has_trial_lesson
    return prices.where(libelle: 'prices.trial_lesson').any?
  end

  def has_unit_course_price
    return (book_tickets.any? or prices.where(libelle: 'prices.individual_course').any?)
  end

  def min_price
    prices.map(&:amount).compact.sort.first
  end

  def max_price
    prices.map(&:amount).compact.sort.last
  end

  def time_slots
    time_slots = []
    plannings.each do |planning|
      if planning.start_time and planning.end_time
        LeBonCours::Application::TIME_SLOTS.each do |time_slot_name, time_slot|
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
    similar_courses   = Course.joins{subjects}.where{subjects.id.eq_any parent_subject_ids}.sample(limit) # With same parent subject
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
    self.plannings.map(&:teacher_name).uniq.compact.length > 1
  end

  def has_teacher?
    self.plannings.map(&:teacher_name).uniq.compact.length > 0
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
    prices.where{amount >= 0}.order('amount ASC').first
  end

  def approximate_price_per_course
    one_class_price = prices.where{nb_course == 1}
    if one_class_price.any?
      return one_class_price.first.amount
    else
      price = prices.where{amount != nil}.order('nb_course DESC').first
      return price.amount / price.nb_course
    end
  end

  def type_name
    'Cours'
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  def friendly_name
    "#{self.slug_type_name}-de-#{self.name}-a-#{city.name}-#{structure.name}"
  end
end
