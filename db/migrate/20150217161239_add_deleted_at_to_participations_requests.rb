class AddDeletedAtToParticipationsRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :deleted_at, :datetime
  end
end
