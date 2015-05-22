class AddStripeChargeIdToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :stripe_charge_id, :string
    add_index :participation_requests, :stripe_charge_id, unique: true
  end
end
