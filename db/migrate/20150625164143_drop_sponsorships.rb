class DropSponsorships < ActiveRecord::Migration
  def up
    drop_table :sponsorships
  end

  def down
    create_table :sponsorships do |t|
      t.references :subscription,    index: true
      t.string     :sponsored_email, null: false
      t.boolean    :consumed,        default: false
      t.datetime   :deleted_at
      t.string     :token

      t.timestamps
    end
  end
end
