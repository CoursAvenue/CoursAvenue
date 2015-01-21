class AddReportReasonIdToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :report_reason_id, :integer
    add_column :participation_requests, :report_reason_text, :text
    add_column :participation_requests, :reported_at, :datetime
  end
end
