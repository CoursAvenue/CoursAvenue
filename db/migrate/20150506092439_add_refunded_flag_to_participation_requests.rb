class AddRefundedFlagToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :refunded, :boolean, default: false
  end
end
