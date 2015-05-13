class AddDurationInMonthsToSubscriptionsCoupons < ActiveRecord::Migration
  def change
    add_column :subscriptions_coupons, :duration_in_months, :integer
  end
end
