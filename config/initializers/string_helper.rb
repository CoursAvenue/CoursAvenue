class String
  def is_number?
    true if Float(self) rescue false
  end

  def is_negative_or_zero_number?
    true if Float(self) <= 0 rescue false
  end
end
