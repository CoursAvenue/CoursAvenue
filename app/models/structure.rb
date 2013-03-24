class Structure < ActiveRecord::Base
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

  attr_accessible :structure_type, :street, :zip_code, :city_id,
                  :place_ids, :name, :info, :registration_info,
                  :gives_professional_courses, :website, :phone_number,
                  :mobile_phone_number, :email_address, :description,
                  :active,
                  :has_validated_conditions,
                  :validated_by,
                  :modification_condition,
                  :cancel_condition,

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

  extend FriendlyId
  friendly_id :name, use: :slugged

  after_initialize :set_free_pricing_plan
  after_create     :create_place
  belongs_to       :city
  belongs_to       :pricing_plan

  has_many :teachers
  has_many :courses
  has_many :renting_rooms
  has_many :cities, through: :places
  has_many :places
  has_many :rooms, through: :places

  has_many :admins

  validates :name               , :presence   => true
  validates :street             , :presence   => true
  validates :zip_code           , :presence   => true, numericality: { only_integer: true }
  validates :city               , :presence   => true
  validates :structure_type     , :presence   => true
  validates :siret              , length: { maximum: 14 }#, numericality: { only_integer: true }


  def main_contact
    admins.first || Admin.new
  end

  private

  def set_free_pricing_plan
    self.pricing_plan = PricingPlan.where(name: 'free').first unless self.pricing_plan.present?
  end

  def create_place
    self.places.create(name: self.name, street: self.street, city: self.city, zip_code: self.zip_code)
  end
end
