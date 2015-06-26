class RemoveUselessFieldsFromCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :ok_nico
    remove_column :courses, :ca_follow_up
    remove_column :courses, :is_promoted
    remove_column :courses, :nb_participants_max
    remove_column :courses, :nb_participants_min
    remove_column :courses, :room_id
    remove_column :courses, :common_price

    remove_column :plannings, :nb_participants_max
    remove_column :plannings, :room_id
  end
end
