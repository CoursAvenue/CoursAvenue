class AddCourseNameToComments < ActiveRecord::Migration
  def change
    add_column :comments, :course_name, :string
    Comment.all.each do |comment|
      comment.update_column :course_name, comment.title
      comment.update_column :title, nil
    end
  end
end
