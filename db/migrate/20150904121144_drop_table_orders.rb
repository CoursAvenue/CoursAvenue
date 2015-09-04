class DropTableOrders < ActiveRecord::Migration
  def change
    drop_table :orders
  end
end
