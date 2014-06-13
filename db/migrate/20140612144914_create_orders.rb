class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string     :order_id
      t.string     :subscription_type
      t.decimal    :amount

      t.references :structure
      t.references :subscription_plan

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
