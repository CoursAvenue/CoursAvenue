class AddTreatmentMethodToParticipationRequest < ActiveRecord::Migration
  def change
    add_column :participation_requests, :treat_method, :string
    ParticipationRequest.where(state: 'treated').update_all(treat_method: 'infos')
  end
end
