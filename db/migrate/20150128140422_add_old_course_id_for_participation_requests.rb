class AddOldCourseIdForParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :old_course_id, :integer
  end
end
