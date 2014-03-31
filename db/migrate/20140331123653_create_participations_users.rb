class CreateParticipationsUsers < ActiveRecord::Migration
  def change
    create_table :participations_users, id: false do |t|
      t.references :participation, :user
    end
    add_index :participations_users, [:participation_id, :user_id]
  end
end
