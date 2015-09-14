class CreateParticipationRequestStates < ActiveRecord::Migration
  def change
    create_table :participation_request_states do |t|
      t.references :participation_request
      t.string :state, default: 'pending'
      t.datetime :accepted_at
      t.datetime :treated_at
      t.datetime :canceled_at
      t.string :treat_method
      t.hstore :metadata

      t.timestamps
    end
  end
end
