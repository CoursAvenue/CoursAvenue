class ChangeLevelAndAudienceToPlanning < ActiveRecord::Migration
  def up
    add_column :plannings, :audience_ids, :string
    add_column :plannings, :level_ids   , :string

    add_index :plannings, :level_ids
    add_index :plannings, :audience_ids

    bar = ProgressBar.new( Course.count + Place.count )

    # 1 Fusion de tous les cours qui ont le même nom
    Place.all.each do |place|
      # Iterating over all courses grouping them by name
      place.courses.group(:name).count.each do |name, count|
        if count > 1
          courses = place.courses.where(name: name)
          course_we_keep = courses.pop
          courses.each do |course|
            course.plannings.update_all course_id: course_we_keep.id
            course.destroy
          end
        end
      end
      bar.increment! 1
    end

    # Affecting audience and levels to course
    Course.all.each do |course|
      course.plannings.each do |planning|
        planning.update_column :level_ids   , course.levels.map(&:order).join(',')
        planning.update_column :audience_ids, course.audiences.map(&:order).join(',')
      end
      bar.increment! 1
    end

    drop_table :courses_levels
    drop_table :audiences_courses
  end

  def down
    create_table :courses_levels, :id => false do |t|
      t.references :level, :course
    end
    add_index :courses_levels, [:course_id, :level_id]

    create_table :audiences_courses, :id => false do |t|
      t.references :course, :audience
    end
    add_index :audiences_courses, [:audience_id, :course_id]

    remove_column :plannings, :audience_ids
    remove_column :plannings, :level_ids

    remove_index :plannings, :level_ids
    remove_index :plannings, :audience_ids

  end
end
