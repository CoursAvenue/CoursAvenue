class RemoveCoursesWithoutStructure < ActiveRecord::Migration
  def up
    Course.all.each do |course|
      course.destroy if course.structure.nil?
    end
  end

  def down
  end
end
