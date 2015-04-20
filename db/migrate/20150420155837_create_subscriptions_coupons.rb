class CreateSubscriptionsCoupons < ActiveRecord::Migration
  def change
    create_table :subscriptions_coupons do |t|
      t.string :name
      t.string :stripe_coupon_id
      t.string :duration

      t.timestamp :deleted_at
      t.timestamps
    end
  end
end
