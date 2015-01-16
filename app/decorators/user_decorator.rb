class UserDecorator < Draper::Decorator
  delegate_all

  # Ex.: 25 ans, Lyon
  def age_and_city
    infos = []
    if age
      infos << "#{age} ans"
    end
    if city
      infos << city.name
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
    if crypted
      string << "XX XX XX XX #{phone_number[-2..-1]}" if phone_number
      string << "<br>" if phone_number and email
      string << email.gsub(/.*@/, 'XXXXXXXXX') if email
    else
      string << phone_number if phone_number
      string << "<br>" if phone_number and email
      string << email if email
    end
    string.html_safe
  end

end
