class AddNbParticipantsMinToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :nb_participants_min, :integer
  end
end
