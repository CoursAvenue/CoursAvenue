class AddManagedAcctionsToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :stripe_managed_account_id, :string
    add_index :structures, :stripe_managed_account_id, unique: true
  end
end
