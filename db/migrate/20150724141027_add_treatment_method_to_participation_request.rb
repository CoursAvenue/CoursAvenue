class AddTreatmentMethodToParticipationRequest < ActiveRecord::Migration
  def change
    add_column :participation_requests, :treat_method, :string
  end
end
