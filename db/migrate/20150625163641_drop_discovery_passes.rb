class DropDiscoveryPasses < ActiveRecord::Migration
  def up
    drop_table :discovery_passes
  end

  def down
    create_table :discovery_passes do |t|
      t.references :user
      t.references :promotion_code

      t.date     :expires_at
      t.date     :renewed_at
      t.datetime :last_renewal_failed_at
      t.boolean  :recurrent
      t.datetime :canceled_at
      t.string   :credit_card_number
      t.string   :be2bill_alias
      t.string   :client_ip
      t.string   :card_validity_date

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
