class AddParticipationRequestsParticipantsTable < ActiveRecord::Migration
  def change
    create_table :participation_request_participants do |t|
      t.integer    :number
      t.datetime   :deleted_at
      t.references :participation_request, :price
    end
    add_index :participation_request_participants, [:participation_request_id, :price_id], :name => 'participation_requests_participants_index'
  end
end
