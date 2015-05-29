class UserDecorator < Draper::Decorator

  # Ex.: 25 ans, Lyon
  def age_and_city
    infos = []
    if object.age
      infos << "#{object.age} ans"
    end
    if object.city
      infos << object.city.name
    end
    infos.join(', ')
  end

  # @param crypted=false Wether we have to show crypted number.
  #
  # @return something like:
  #   06 07 65 33 23
  #   <br>
  #   nim.izadi@gmail.com
  # And if crypted:
  #   XX XX XX XX 23
  #   <br>
  #   XXXXXXXXX@gmail.com
  def phone_number_and_email(crypted=false)
    string = ""
    string << phone_number(crypted) if object.phone_number
    string << "<br>" if object.phone_number and object.email
    string << email(crypted) if object.email
    string.html_safe
  end

  def phone_number(crypted=false)
    if crypted
      "XX XX XX XX #{object.phone_number[-2..-1]}" if object.phone_number
    else
      PhoneNumberDecorator.new(PhoneNumber.new(number: object.phone_number)).formatted_number if object.phone_number
    end
  end

  def email(crypted=false)
    if crypted
      object.email.gsub(/.*@/, 'XXXXXXXXX@') if object.email
    else
      object.email if object.email
    end
  end

  def full_name
    object.full_name
  end
end
