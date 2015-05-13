class AddMaxRedemptionsToSubscriptionsCoupons < ActiveRecord::Migration
  def change
    add_column :subscriptions_coupons, :max_redemptions, :integer
  end
end
