module Concerns
  module SMSSender
    extend ActiveSupport::Concern

    included do
      # Send a SMS to the Structure main contact or to the User.
      #
      # @param message          - The message to send in a String.
      # @param recipient_number - The PhoneNumber of the person who will receive the message.
      #
      # @return a boolean, whether the message was sent or not.
      def self.send_sms(message, recipient_number)
        client = Nexmo::Client.new

        client.send_message(from: 'CoursAvenue', to: recipient_number, text: message)
      end
    end
  end
end
