class Place < ActiveRecord::Base
  unless Rails.env.test?
    acts_as_gmappable validation: false,
                      language: 'fr' # :msg => "Désolé, même Google n'a pas trouvé où l'établissement se trouve."
    before_save :retrieve_address
  end

  belongs_to              :city
  has_many                :courses
  has_and_belongs_to_many :structures
  attr_accessible :contact_email, :contact_name, :contact_phone, :contact_mobile_phone, :has_handicap_access, :info, :name, :nb_room, :street, :zip_code, :city, :latitude, :longitude, :gmaps, :city_id

  # describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  def gmaps4rails_address
    "#{self.street}, #{self.zip_code}, France"
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
    !self.latitude.nil? and self.longitude.nil?
  end
  def geolocalize
    self.touch
    self.save
  end
end
