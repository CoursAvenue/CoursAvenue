class AddSlugForCourseGroup < ActiveRecord::Migration
  def change
    add_column :course_groups, :slug, :string
    add_index  :course_groups, :slug, unique: true
  end
end
