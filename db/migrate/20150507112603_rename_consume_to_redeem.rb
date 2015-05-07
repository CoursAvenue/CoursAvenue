class RenameConsumeToRedeem < ActiveRecord::Migration
  def change
    rename_column :subscriptions_sponsorships, :consumed, :redeemed
  end
end
