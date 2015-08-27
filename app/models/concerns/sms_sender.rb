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
        client           = NexmoClientFactory.client
        recipient_number = formatted_number(recipient_number)
        recipient_number = formatted_number(ENV['INTERCEPTOR_NUMBER']) if ENV['INTERCEPTOR_NUMBER'].present?

        if uses_mobile?(recipient_number)
          SmsLogger.create(sender: self, number: recipient_number, text: message.strip)
          client.send_message(from: 'CoursAvenue', to: recipient_number, text: message.strip)
        end
      end

      # Format the receiver's phone number so a message can be sent to it.
      #
      # @param phone_number - The phone number to format.
      #
      # @return The formated phone number as a String.
      def formatted_number(phone_number)
        number = phone_number.dup
        number = number.gsub(' ', '').gsub('.', '').gsub('-', '').gsub('/', '')

        PhoneNumber::MOBILE_PREFIXES.each do |prefix|
          if number.starts_with? prefix
            number = number.gsub prefix, "0033#{prefix.last}" #.last because last is 6 or 7
            break
          end
        end
        number
      end

      # Checks if the receiver's phone number is a mobile.
      #
      # @param phone_number - The phone number to test.
      #
      # @return a Boolean
      def uses_mobile?(phone_number)
        PhoneNumber::MOBILE_PREFIXES.any? { |prefix| phone_number.starts_with?(prefix) }
      end

    end
  end
end
