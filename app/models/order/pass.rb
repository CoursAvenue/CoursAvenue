# Do not remove, there are orders whith type: Order::Pass in the DB
class Order::Pass < Order

  def order_template
    'users/orders/export.pdf.haml'
  end
end
