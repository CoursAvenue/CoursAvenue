class Structure < ActiveRecord::Base
  unless Rails.env.test?
    acts_as_gmappable validation: false,
                      language: 'fr' # :msg => "Désolé, même Google n'a pas trouvé où l'établissement se trouve."
    before_save :retrieve_address
  end

  belongs_to :city
  has_many :courses
  has_many :renting_rooms

  validates :name, :presence   => true
  validates :name, :uniqueness => true

  attr_accessible :city,
                  :structure_type,
                  :name,
                  :place_name,                  # To use
                  :info,
                  :street,
                  :adress_info,
                  :registration_info,
                  :zip_code,
                  :has_handicap_access,
                  :is_professional,             # To use
                  :nb_room,
                  :website,
                  :phone_number,
                  :mobile_phone_number,
                  :email_address,               # To do Info structure
                  # Mettre un lien pour CIF, DIF etc.
                  # Moyen de financements possible :
                  :accepts_holiday_vouchers,    # To use Info prix Chèques Vacances
                  :accepts_ancv_sports_coupon,  # To use Info prix Coupons Sports ANCV
                  :accepts_leisure_tickets,     # To use Info prix Tickets Loisirs C.A.F. (y compris les "Tickets Temps Libres")
                  :accepts_afdas_funding,       # To use Info prix AFDAS
                  :accepts_dif_funding,         # To use Info prix DIF
                  :accepts_cif_funding,         # To use Info prix CIF

                  # For registration info
                  :has_registration_form,
                  :needs_photo_id_for_registration,
                  :needs_id_copy_for_registration,
                  :needs_medical_certificate_for_registration, # certificat médical de moins de 3 mois
                  :needs_insurance_attestation_for_registration # attestation d'assurance


  # describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  def gmaps4rails_address
    "#{self.street}, #{self.zip_code}, Paris France"
  end

  def retrieve_address
    if !self.new_record? and !self.is_geolocalized?
      begin
        geolocation    = Gmaps4rails.geocode self.gmaps4rails_address
        self.latitude  = geolocation[:lat]
        self.longitude = geolocation[:lng]
        self.save
      rescue Exception => e
        puts "Address not found: #{e}"
      end
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
