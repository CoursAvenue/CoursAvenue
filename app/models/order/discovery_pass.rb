class Order::DiscoveryPass < Order

  ######################################################################
  # Relations                                                          #
  ######################################################################

  ######################################################################
  # Callbacks                                                          #
  ######################################################################

  def self.next_order_id_for(structure)
    order_number = structure.orders.count + 1
    "FR#{Date.today.year}#{structure.id}#{order_number}"
  end
end
