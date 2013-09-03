class Price::Registration < Price
  def registration?
    true
  end

  def free?
    amount == 0
  end
end
