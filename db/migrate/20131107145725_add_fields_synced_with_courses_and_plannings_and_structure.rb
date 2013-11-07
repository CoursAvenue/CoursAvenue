class AddFieldsSyncedWithCoursesAndPlanningsAndStructure < ActiveRecord::Migration
  def up
    add_column :structures, :audience_ids,             :string
    add_column :structures, :gives_group_courses,      :boolean
    add_column :structures, :gives_individual_courses, :boolean

    bar = ProgressBar.new(Structure.count + Course.count)
    Structure.find_each do |s|
      bar.increment!
      s.delay.send(:update_synced_attributes)
    end

    Course.find_each(batch_size: 100) do |course|
      bar.increment!
      course.send(:set_teaches_at_home)
      course.save(validate: false)
    end
  end

  def down
    remove_column :structures, :audience_ids
    remove_column :structures, :gives_group_courses
    remove_column :structures, :gives_individual_courses
  end
end
