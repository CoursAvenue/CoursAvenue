class AddPreviouslyPlannedAtToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :previously_planned_at, :datetime, default: nil
  end
end
