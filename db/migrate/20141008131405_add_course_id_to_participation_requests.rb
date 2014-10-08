class AddCourseIdToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :course_id, :integer
  end
end
