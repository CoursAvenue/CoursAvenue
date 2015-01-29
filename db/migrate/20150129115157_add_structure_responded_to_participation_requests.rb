class AddStructureRespondedToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :structure_responded, :boolean, default: false
  end
end
