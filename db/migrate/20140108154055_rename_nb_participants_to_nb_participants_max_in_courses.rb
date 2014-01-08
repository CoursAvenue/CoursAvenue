class RenameNbParticipantsToNbParticipantsMaxInCourses < ActiveRecord::Migration
  def change
    rename_column :courses, :nb_participants, :nb_participants_max
  end
end
