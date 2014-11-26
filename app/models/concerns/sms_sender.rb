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
      def send_sms(message, recipient_number)
        client = Nexmo::Client.new

        client.send_message(from: 'CoursAvenue', to: recipient_number, text: message)
      end

      # Format the receiver's phone number so a message can be sent to it.
      #
      # @param phone_number - The phone number to format.
      #
      # @return The formated phone number as a String.
      def formatted_number(phone_number = self.phone_number)
        number = phone_number.dup
        number.gsub! ' ', ''

        if number.starts_with? '06', '07', '+33'
          number.gsub! /^0|\+33/, '0033'
        end

        number
      end

      # Checks if the receiver's phone number is a mobile.
      #
      # @param phone_number - The phone number to test.
      #
      # @return a Boolean
      def uses_mobile?(phone_number = self.phone_number)
        number = phone_number.dup

        PhoneNumber::MOBILE_PREFIXES.any? { |prefix| number.starts_with?(prefix) }
      end

    end
  end
end
