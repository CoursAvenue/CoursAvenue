class Structure < ActiveRecord::Base
  acts_as_gmappable validation: false,
                    language: 'fr' # :msg => "Désolé, même Google n'a pas trouvé où l'établissement se trouve."
  before_save :retrieve_address

  has_many :course_groups
  has_many :renting_rooms

  # attr_accessible :logo
  # attr_accessible :photo
  # has_attached_file :logo
  # has_attached_file :photo

  validates :name, :presence   => true
  validates :name, :uniqueness => true

  attr_accessible :adress_info,
                  :structure_type,
                  :name,
                  :name_2,
                  :info,
                  :registration_info,
                  :street,
                  :nb_days_before_cancelation,
                  :zip_code,
                  :closed_days,
                  :has_handicap_access,
                  :is_professional,
                  :nb_room,
                  :website,
                  :newsletter_address,
                  :has_online_reservation,
                  :online_reservation_website,
                  :onlne_reservation_mandatory,
                  :has_online_membership,
                  :online_membership_website,
                  :phone_number,
                  :mobile_phone_number,
                  :email_address,
                  :email_address_2,
                  :contact_name,
                  :accepts_holiday_vouchers,
                  :accepts_ancv_sports_coupon,
                  :accepts_leisure_tickets,
                  :accepts_afdas_funding,
                  :accepts_dif_funding,
                  :accepts_cif_funding,
                  :has_multiple_place,
                  :has_annual_course_only,

                  # For registration info
                  :has_registration_form,
                  :needs_photo_id_for_registration,
                  :needs_id_copy_for_registration,
                  :needs_payment_on_place_for_registration, # règlement sur place
                  :needs_medical_certificate_for_registration, # certificat médical de moins de 3 mois
                  :needs_insurance_attestation_for_registration # attestation d'assurance


  # describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  def gmaps4rails_address
    "#{self.street}, #{self.zip_code}, France"
  end

  def retrieve_address
    if self.latitude == nil
      geolocation    = Gmaps4rails.geocode self.gmaps4rails_address[0]
      self.latitude  = geolocation[:lat]
      self.longitude = geolocation[:lng]
      self.save
    end
  end

  def is_geolocalized?
    !self.gmaps.nil? and self.gmaps
  end

  def geolocalize
    self.touch
    self.save
  end
end
