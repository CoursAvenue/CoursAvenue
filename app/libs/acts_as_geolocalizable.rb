# TODO: Move this into a concern
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
      [street, city.name].compact.join(' ') + ', France'
    end
  end
end
