module ActsAsGeolocalizable

  def self.included(base)
    base.instance_eval do
      include ::ActsAsGeolocalizable::InstanceMethods
    end
  end

  module InstanceMethods

    def address
      "#{self.street}, #{self.city.name}"
    end

    def geocoder_address
      [street, zip_code, city, 'France'].compact.join(', ')
    end
  end
end
