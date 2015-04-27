class AddTokenToParticipationRequest < ActiveRecord::Migration
  def change
    add_column :participation_requests, :token, :string
  end
end
