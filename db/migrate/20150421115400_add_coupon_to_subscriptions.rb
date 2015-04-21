class AddCouponToSubscriptions < ActiveRecord::Migration
  def change
    add_reference :subscriptions, :subscriptions_coupon, index: true
  end
end
