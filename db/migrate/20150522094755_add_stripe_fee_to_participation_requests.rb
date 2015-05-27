class AddStripeFeeToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :stripe_fee, :float
  end
end
