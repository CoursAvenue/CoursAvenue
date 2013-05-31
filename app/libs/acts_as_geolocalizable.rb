module ActsAsGeolocalizable

  def self.included(base)
    base.instance_eval do
      include ::ActsAsGeolocalizable::InstanceMethods
    end
  end

  module InstanceMethods

    def gmaps4rails_address
      if city
        "#{self.street}, #{self.city.name}, France"
      else
        "#{self.street}, #{self.zip_code}, France"
      end
    end

    def retrieve_address
      if !self.new_record? and !self.is_geolocalized?
        begin
          geolocation    = Gmaps4rails.geocode(self.gmaps4rails_address).first
          self.update_column :latitude, geolocation[:lat]
          self.update_column :longitude, geolocation[:lng]
        rescue Exception => e
          puts "Address not found: #{e}"
          begin
            geolocation    = Gmaps4rails.geocode("#{self.city.name}, France").first
            self.update_column :latitude, geolocation[:lat]
            self.update_column :longitude, geolocation[:lng]
          rescue Exception => e
            puts "Address not found: #{e}"
          end
        end
      end
    end

    def is_geolocalized?
      !self.latitude.nil? and !self.longitude.nil?
    end

    def geolocalize
      self.touch
      self.save
    end

    def address
      "#{self.street}, #{self.city.name}"
    end
  end
end
