class AddExpiresAtToSubscriptionsPlans < ActiveRecord::Migration
  def change
    add_column :subscriptions, :expires_at, :datetime
  end
end
