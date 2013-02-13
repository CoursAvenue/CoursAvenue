class Structure < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

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
                  :city_id,
                  :structure_type,
                  :name,
                  :place_name,
                  :info,
                  :street,
                  :adress_info,
                  :registration_info,
                  :zip_code,
                  :has_handicap_access,
                  :gives_professional_courses,
                  :nb_room,
                  :website,
                  :phone_number,
                  :mobile_phone_number,
                  :email_address,
                  # Moyen de financements possible :
                  :accepts_holiday_vouchers,
                  :accepts_ancv_sports_coupon,
                  :accepts_leisure_tickets,
                  :accepts_afdas_funding,
                  :accepts_dif_funding,
                  :accepts_cif_funding,

                  :latitude,
                  :longitude,
                  :gmaps,
                  :slug,

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
