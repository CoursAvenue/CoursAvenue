class AddCancelationReasonToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :cancelation_reason_id, :integer
  end
end
