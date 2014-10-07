class Order::Pass < Order

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :user

  ######################################################################
  # Callbacks                                                          #
  ######################################################################

  #
  # Generates a unique Order ID for a given user
  # @param user
  #
  # @return String: Unique string
  def self.next_order_id_for user
    order_number = user.orders.count + 1
    "FR#{Date.today.year}_#{user.id}#{order_number}"
  end

end
