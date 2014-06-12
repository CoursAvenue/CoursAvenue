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
end
