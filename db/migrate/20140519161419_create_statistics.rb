class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.references :structure

      t.string     :action_type
      t.string     :user_fingerprint
      t.text       :infos

      t.time       :deleted_at

      t.timestamps
    end
  end
end
