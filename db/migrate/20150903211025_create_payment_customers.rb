class CreatePaymentCustomers < ActiveRecord::Migration
  def change
    create_table :payment_customers do |t|
      t.string :stripe_customer_id
      t.references :client, polymorphic: true

      t.timestamps
    end
  end
end
