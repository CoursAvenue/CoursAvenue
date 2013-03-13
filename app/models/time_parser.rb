module TimeParser

  def parse_time_string time_string
    return nil if time_string.blank?
    # If the time_string is like "25m"
    if time_string.include? 'm' and (!time_string.include? 'h' or !time_string.include? ':')
      time_string = "00h#{time_string}"
    elsif time_string.length <= 2
      time_string += ':00'
    end
    Time.parse("2000-01-01 #{time_string} UTC")
  end

  def self.parse_time_string time_string
    return nil if time_string.blank?
    # If the time_string is like "25m"
    if time_string.include? 'm' and (!time_string.include? 'h' or !time_string.include? ':')
      time_string = "00h#{time_string}"
    elsif time_string.length <= 2
      time_string += ':00'
    end
    Time.parse("2000-01-01 #{time_string} UTC")
  end


  def self.end_time_from_duration(start_time, duration)
    return nil if duration.nil? or start_time.nil?
    temp_time = start_time
    temp_time = temp_time + duration.hour.hour
    temp_time = temp_time + duration.min.minutes
    return temp_time
  end

  def self.duration_from(start_time, end_time)
    TimeParser.parse_time_string(Time.at((end_time - start_time)).gmtime.strftime('%R:%S'))
  end

end
