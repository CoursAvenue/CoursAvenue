class Structure < ActiveRecord::Base
  STRUCTURE_TYPES = ["structures.private_center", "structures.public_center", "structures.community_center", "structures.independant", "structures.museum"]
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :courses
  has_many :renting_rooms
  has_many :cities, through: :places
  has_many :places

  has_many :admin_users

  validates :name, :presence   => true
  # validates :name, :uniqueness => true

  attr_accessible :structure_type,
                  :place_ids,
                  :name,
                  :info,
                  :registration_info,
                  :gives_professional_courses,
                  :website,
                  :phone_number,
                  :mobile_phone_number,
                  :email_address,

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
                  :needs_insurance_attestation_for_registration # attestation d'assurance

end
