class AddRefundedAtToParticipationRequests < ActiveRecord::Migration
  def up
    remove_column :participation_requests, :refunded
    add_column :participation_requests, :refunded_at, :datetime
  end

  def down
    remove_column :participation_requests, :refunded_at
    add_column :participation_requests, :refunded, :boolean
  end
end
