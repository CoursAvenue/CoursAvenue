module Concerns
  module HasDeliveryStatus
    extend ActiveSupport::Concern

    # Tell wether we can send email or not
    #
    # @return Boolean
    def should_send_email?
       self.delivery_email_status.nil?
    end
  end
end
