class AddNbParticipantsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :nb_participants, :integer
  end
end
