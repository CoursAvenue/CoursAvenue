class AddCouponEndsAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :coupon_ends_at, :datetime
  end
end
