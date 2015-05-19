class CreateSubscriptionsSponsorships < ActiveRecord::Migration
  def change
    create_table :subscriptions_sponsorships do |t|
      t.references :subscription,    index: true
      t.string     :sponsored_email, null: false
      t.boolean    :consumed,        default: false
      t.datetime   :deleted_at
      t.string     :token

      t.timestamps
    end
  end
end
