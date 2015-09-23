class AddTreatmentDateToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :treated_at, :datetime
  end
end
