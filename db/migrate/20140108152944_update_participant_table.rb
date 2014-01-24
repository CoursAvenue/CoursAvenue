class UpdateParticipantTable < ActiveRecord::Migration
  def up
    drop_table :participants

    create_table :participations do |t|
      t.references :user
      t.references :planning

      t.timestamps
    end
    add_index :participations, [:planning_id, :user_id]
  end

  def down
    drop_table :participations
    create_table :participants do |t|
      t.references :user
      t.references :planning

      t.timestamps
    end
    add_index :participants, [:planning_id, :user_id]
  end
end
