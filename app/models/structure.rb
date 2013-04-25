class Structure < ActiveRecord::Base
  acts_as_paranoid

  STRUCTURE_STATUS        = %w(SA SAS SASU EURL SARL)
  STRUCTURE_TYPES         = ['structures.company',
                             'structures.independant',
                             'structures.association',
                             'structures.board',
                             'structures.intermittent',
                             'structures.liberal']

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
                  :gives_professional_courses, :website, :phone_number,
                  :mobile_phone_number, :email_address, :description,
                  :active,
                  :has_validated_conditions,
                  :validated_by,
                  :modification_condition,
                  :cancel_condition,
                  :image,

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
                    :styles => { wide: "800x480#", thumb: "200x200#" }

  extend FriendlyId
  friendly_id :name, use: :slugged

  after_create     :create_teacher
  after_create     :set_free_pricing_plan
  after_create     :create_place

  belongs_to       :city
  belongs_to       :pricing_plan

  has_many :teachers
  has_many :subjects, through: :courses
  has_many :courses, through: :places
  has_many :renting_rooms
  has_many :cities, through: :places
  has_many :places
  has_many :rooms, through: :places

  has_many :admins

  validates :name               , :presence   => true
  validates :street             , :presence   => true, on: :create
  validates :zip_code           , :presence   => true, numericality: { only_integer: true }, on: :create
  validates :city               , :presence   => true, on: :create
  # validates :structure_type     , :presence   => true
  validates :siret              , length: { maximum: 14 }#, numericality: { only_integer: true }

  before_save :replace_slash_n_r_by_brs

  def course_with_planning
    self.courses.joins{plannings}.where{plannings.end_date > Date.today}.group(:id)
  end

  def main_contact
    admins.first || Admin.new
  end

  def address
    "#{self.street}, #{self.city.name}"
  end

  def parent_subjects
    subjects.uniq.map(&:parent).uniq
  end

  def description_for_input
    self.description.gsub(/<br>/, '&#x000A;').html_safe if self.description
  end

  private

  def set_free_pricing_plan
    self.pricing_plan = PricingPlan.where(name: 'free').first unless self.pricing_plan.present?
  end

  def create_place
    self.places.create(name: self.name, street: self.street, city: self.city, zip_code: self.zip_code)
  end

  def create_teacher
    if teachers.empty? and main_contact
      self.teachers.create(name: main_contact.name)
    end
  end

  def replace_slash_n_r_by_brs
    self.description = self.description.gsub(/\r\n/, '<br>') if self.description
  end

end
