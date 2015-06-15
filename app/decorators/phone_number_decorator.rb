class PhoneNumberDecorator < Draper::Decorator

  # Return string as: 0X XX XX XX XX
  def formatted_number
    number = object.number
    number = number.gsub(' ', '').gsub('.', '').gsub('-', '')

    PhoneNumber::FRANCE_PREFIXES.each do |prefix|
      if number.starts_with? prefix
        number = number.gsub prefix, '0' #.last because last is 6 or 7
        break
      end
    end
    "#{number[0..1]} #{number[2..3]} #{number[4..5]} #{number[6..7]} #{number[8..9]}"
  end
end
