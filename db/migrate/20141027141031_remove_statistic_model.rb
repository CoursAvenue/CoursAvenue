class RemoveStatisticModel < ActiveRecord::Migration
  def up
    drop_table :statistics
  end

  def down
    create_table :statistics do |t|
      t.references :structure

      t.string     :action_type
      t.string     :user_fingerprint
      t.string     :ip_address
      t.text       :infos

      t.time       :deleted_at

      t.timestamps
    end
  end
end
