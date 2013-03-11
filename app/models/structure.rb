class Structure < ActiveRecord::Base
  STRUCTURE_STATUS = %w(SA SAS SASU EURL SARL)
  STRUCTURE_TYPES = ['structures.company',
                      'structures.association',
                      'structures.board',
                      'structures.independant',
                      'structures.private_structure',
                      'structures.liberal']
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :teachers
  has_many :courses
  has_many :renting_rooms
  has_many :cities, through: :places
  has_many :places

  has_many :admins

  validates :name, :presence   => true
  validates :structure_type, :presence   => true
  validates :siret, length: { maximum: 14 }#, numericality: { only_integer: true }
  # validates :name, :uniqueness => true

  attr_accessible :structure_type,
                  :address,
                  :zip_code,
                  :city_name,
                  :place_ids,
                  :name,
                  :info,
                  :registration_info,
                  :gives_professional_courses,
                  :website,
                  :phone_number,
                  :mobile_phone_number,
                  :email_address,
                  :description,

                  ## Moyen de financements possible :
                  :accepts_holiday_vouchers,
                  :accepts_ancv_sports_coupon,
                  :accepts_leisure_tickets,
                  :accepts_afdas_funding,
                  :accepts_dif_funding,
                  :accepts_cif_funding,

                  # For registration info
                  :has_registration_form,
                  :needs_photo_id_for_registration,
                  :needs_id_copy_for_registration,
                  :needs_medical_certificate_for_registration, # certificat médical de moins de 3 mois
                  :needs_insurance_attestation_for_registration, # attestation d'assurance

                  :siret,
                  :tva_intracom_number,
                  :structure_status,
                  :billing_contact_first_name,
                  :billing_contact_last_name,
                  :billing_contact_phone_number,
                  :billing_contact_email,
                  :bank_name,
                  :bank_iban,
                  :bank_bic

  def main_contact
    admins.first || Admin.new
  end
end
