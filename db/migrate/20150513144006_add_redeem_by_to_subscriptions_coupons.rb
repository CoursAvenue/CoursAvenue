class AddRedeemByToSubscriptionsCoupons < ActiveRecord::Migration
  def change
    add_column :subscriptions_coupons, :redeem_by, :datetime
  end
end
