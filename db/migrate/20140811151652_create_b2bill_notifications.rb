class CreateB2billNotifications < ActiveRecord::Migration
  def change
    create_table :b2bill_notifications do |t|
      t.text :params
      t.integer :structure_id
      t.string :order_id
      t.timestamps
    end
  end
end
