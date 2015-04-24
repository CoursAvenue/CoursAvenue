class AddStripeKeysToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :stripe_managed_account_secret_key,      :string
    add_column :structures, :stripe_managed_account_publishable_key, :string

    add_index :structures,  :stripe_managed_account_secret_key,      unique: true
    add_index :structures,  :stripe_managed_account_publishable_key, unique: true
  end
end
