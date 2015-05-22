class AddChargedAtToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :charged_at, :datetime
  end
end
