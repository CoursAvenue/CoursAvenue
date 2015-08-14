class StringHelper
  def self.sanatize string
    string = self.reject_vertical_tab string
    string.scan(/[[:print:]]|[[:space:]]/).join
  end

  def self.reject_vertical_tab string
    string.chars.inject("") do |str, char|
      unless char.ord == 11
        str << char
      end
      str
    end
  end

  def self.replace_email_address(string)
    string.gsub(/([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})/i, '*********') if string
  end

  def self.replace_phone_numbers(string)
    string.gsub(/([0-9][0-9]( |\-|\.)?){5}/, '**********') if string
  end

  def self.replace_links(string)
    string.gsub(/((http|ftp|https):\/\/)?[\w\-_]{2,}(\(point\)[\w\-_]|\.[\w\-_])+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?/i, '*************') if string
  end

  def self.replace_email_and_phones(string)
    string = StringHelper.replace_email_address(string)
    string = StringHelper.replace_phone_numbers(string)
    string
  end

  def self.replace_contact_infos(string)
    string = StringHelper.replace_email_address(string)
    string = StringHelper.replace_phone_numbers(string)
    string = StringHelper.replace_links(string)
    string
  end

end
