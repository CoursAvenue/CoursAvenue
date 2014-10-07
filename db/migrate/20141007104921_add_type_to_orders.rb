class AddTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :type, :string
    Order.update_all type: 'Order::SubscriptionPlan'
  end
end
