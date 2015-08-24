class AddCourseToComments < ActiveRecord::Migration
  def change
    add_reference :comments, :course, index: true
  end
end
