class CreateParticipationRequests < ActiveRecord::Migration
  def change
    create_table :participation_requests do |t|
      t.references :mailboxer_conversation
      t.references :planning
      t.references :user
      t.references :structure

      t.string     :state
      t.string     :last_modified_by
      t.date       :date
      t.time       :start_time
      t.time       :end_time

      t.timestamps
    end
  end
end
