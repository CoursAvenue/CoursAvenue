module TimeParser

  def parse_time_string time_string
    if time_string.length <= 2
      time_string += ':00'
    end
    Time.parse("2000-01-01 #{time_string} UTC")
  end

  def self.parse_time_string time_string
    if time_string.length <= 2
      time_string += ':00'
    end
    Time.parse("2000-01-01 #{time_string} UTC")
  end

end
