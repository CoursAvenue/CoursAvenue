class Structure < ActiveRecord::Base
  acts_as_paranoid
  include HasSubjects
  include ActsAsCommentable

  extend FriendlyId
  friendly_id :name, use: :slugged

  STRUCTURE_STATUS        = %w(SA SAS SASU EURL SARL)
  STRUCTURE_TYPES         = ['structures.company',
                             'structures.independant',
                             'structures.association',
                             'structures.board']

  CANCEL_CONDITIONS       = ['structures.cancel_conditions.flexible',
                             'structures.cancel_conditions.moderate',
                             'structures.cancel_conditions.strict',
                             'structures.cancel_conditions.very_strict']

  MODIFICATION_CONDITIONS = ['structures.modification_conditions.flexible',
                             'structures.modification_conditions.moderate',
                             'structures.modification_conditions.strict']

  attr_reader :delete_image
  attr_accessible :structure_type, :street, :zip_code, :city_id,
                  :place_ids, :name, :info, :registration_info,
                  :gives_professional_courses, :website, :facebook_url, :phone_number,
                  :mobile_phone_number, :contact_email, :description,
                  :subject_ids,
                  :active,
                  :has_validated_conditions,
                  :validated_by,
                  :modification_condition,
                  :cancel_condition,
                  :image,
                  :rating, :comments_count,
                  :no_facebook, :no_website,

                  ## Moyen de financements possible :
                  :accepts_holiday_vouchers, :accepts_ancv_sports_coupon, :accepts_leisure_tickets,
                  :accepts_afdas_funding, :accepts_dif_funding, :accepts_cif_funding,

                  # For registration info
                  :has_registration_form, :needs_photo_id_for_registration, :needs_id_copy_for_registration,
                  :needs_medical_certificate_for_registration, # certificat médical de moins de 3 mois
                  :needs_insurance_attestation_for_registration, # attestation d'assurance

                  :siret, :tva_intracom_number, :structure_status, :billing_contact_first_name,
                  :billing_contact_last_name, :billing_contact_phone_number, :billing_contact_email,
                  :bank_name, :bank_iban, :bank_bic

  has_attached_file :image,
                    styles:          { wide: '800x480#', thumb: '200x200#', normal: '450x' },
                    convert_options: { wide: '-interlace Line', thumb: '-interlace Line', normal: '-interlace Line' }

  belongs_to       :city
  belongs_to       :pricing_plan

  has_many :medias,   as: :mediable   , dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :students
  has_many :teachers                  , dependent: :destroy
  has_many :courses , through: :places
  has_many :renting_rooms
  has_many :cities, through: :places
  has_many :places                    , dependent: :destroy
  # has_many :rooms, through: :places
  has_and_belongs_to_many :subjects

  has_many :admins

  validates :name               , :presence   => true
  validates :street             , :presence   => true, on: :create
  validates :zip_code           , :presence   => true, numericality: { only_integer: true }, on: :create
  validates :city               , :presence   => true, on: :create
  # validates :structure_type     , :presence   => true
  validates :siret              , length: { maximum: 14 }#, numericality: { only_integer: true }


  # -------------------- Callbacks
  before_create    :set_active_to_true

  after_create     :set_free_pricing_plan
  after_create     :create_place
  after_create     :create_courses_relative_to_subject
  after_create     :delay_subscribe_to_mailchimp if Rails.env.production?

  after_save       :create_teacher

  before_save      :replace_slash_n_r_by_brs
  before_save      :fix_website_url

  def update_comments_count
    self.update_column :comments_count, self.all_comments.count
  end

  def contact_email
    if admins.any?
      admins.first.email
    else
      read_attribute(:contact_email)
    end
  end

  def main_contact
    admins.first
  end

  def address
    "#{self.street}, #{self.city.name}"
  end

  def all_comments
    commentable_ids = self.courses.collect(&:id)
    course_comments = Comment.order('created_at ASC').where{(commentable_id.in commentable_ids) & (commentable_type == 'Course')}.all
    (self.comments + course_comments).reject(&:new_record?).sort {|c1, c2| c2.created_at <=> c1.created_at}
    # _comments = self.comments + self.courses.with_deleted.collect(&:comments).flatten
    # _comments.reject(&:new_record?).sort {|c1, c2| c2.created_at <=> c1.created_at}
  end


  def parent_subjects
    subjects.uniq.map(&:parent).uniq
  end

  def description_for_input
    self.description.gsub(/<br>/, '&#x000A;').html_safe if self.description
  end

  def description_for_meta
    self.description.gsub(/<br>/, ' ').html_safe if self.description
  end

  def contact_name
    if self.admins.any?
      self.admins.first.name
    end
  end

  def independant?
    structure_type == 'structures.independant'
  end

  def activate!
    self.active = true
    self.save
    self.places.each { |place| place.index }
  end

  def disable!
    self.active = false
    self.save
    self.courses.each do |course|
      course.active = false
      course.save
    end
  end

  private

  def set_free_pricing_plan
    self.pricing_plan = PricingPlan.where(name: 'free').first unless self.pricing_plan.present?
  end

  def create_place
    self.places.create(name: 'Adresse principale', street: self.street, city: self.city, zip_code: self.zip_code)
  end

  def create_courses_relative_to_subject
    place = self.places.first
    self.subjects.each do |subject|
      place.courses.create(name: subject.name, subject_ids: [subject.id], type: 'Course::Lesson', start_date: Date.today, end_date: (Date.today + 1.year))
    end
  end

  def create_teacher
    if teachers.empty? and !main_contact.nil?
      self.teachers.create(name: main_contact.name)
    end
  end

  def replace_slash_n_r_by_brs
    self.description = self.description.gsub(/\r\n/, '<br>') if self.description
  end

  def set_active_to_true
    self.active = true
  end

  def delay_subscribe_to_mailchimp
    self.delay.subscribe_to_mailchimp
  end

  def subscribe_to_mailchimp
    nb_comments = self.comments_count
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_TEACHERS_LIST_ID,
                           :email_address => self.contact_email,
                           :merge_vars => {
                              :NAME       => self.name,
                              :STATUS     => (self.admins.any? ? 'registered' : 'not registered'),
                              :NB_COMMENT => nb_comments,
                              :SLUG       => self.slug
                           },
                           :double_optin => false,
                           :update_existing => true,
                           :send_welcome => false})
  end

  def fix_website_url
    if self.website.present? and !self.website.starts_with? 'http://'
      self.website = "http://#{self.website}"
    end
  end
end
