class AddCaFollowUpOnCourses < ActiveRecord::Migration
  def change
    add_column :courses, :ca_follow_up, :text
  end
end
