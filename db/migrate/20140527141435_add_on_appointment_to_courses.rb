class AddOnAppointmentToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :on_appointment, :boolean, default: false
    Course.update_all on_appointment: false
  end
end
