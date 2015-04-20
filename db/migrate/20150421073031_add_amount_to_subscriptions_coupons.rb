class AddAmountToSubscriptionsCoupons < ActiveRecord::Migration
  def change
    add_column :subscriptions_coupons, :amount, :integer
  end
end
