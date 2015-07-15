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

  # @return something like:
  #   06 07 65 33 23
  #   <br>
  #   nim.izadi@gmail.com
  def phone_number_and_email
    string = ""
    string << phone_number if object.phone_number
    string << "<br>" if object.phone_number and object.email
    string << email if object.email
    string.html_safe
  end

  def phone_number
    PhoneNumberDecorator.new(PhoneNumber.new(number: object.phone_number)).formatted_number if object.phone_number
  end

  def email
    object.email if object.email
  end

  def full_name
    object.full_name
  end
end
