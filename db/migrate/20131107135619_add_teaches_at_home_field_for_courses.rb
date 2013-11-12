class AddTeachesAtHomeFieldForCourses < ActiveRecord::Migration

  def up
    add_column :courses, :teaches_at_home, :boolean
    bar = ProgressBar.new Course.count
    Course.find_each(batch_size: 100) do |course|
      bar.increment!
      course.send(:set_teaches_at_home)
      course.save(validate: false)
    end
  end

  def down
    remove_column :courses, :teaches_at_home
  end
end
