class ChangeAmountTypeInCoupons < ActiveRecord::Migration
  def change
    change_column :subscriptions_coupons, :amount, :float
  end
end
