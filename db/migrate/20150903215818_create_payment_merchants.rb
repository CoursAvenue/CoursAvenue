class CreatePaymentMerchants < ActiveRecord::Migration
  def change
    create_table :payment_merchants do |t|
      t.string :stripe_managed_account_id
      t.string :stripe_managed_account_secret_key
      t.string :stripe_managed_account_publishable_key
      t.references :structure, index: true

      t.timestamps
    end
    add_index :payment_merchants, :stripe_managed_account_id
    add_index :payment_merchants, :stripe_managed_account_secret_key
    add_index :payment_merchants, :stripe_managed_account_publishable_key,
      name: 'merchants_stripe_managed_account_publishable_key'
  end
end
