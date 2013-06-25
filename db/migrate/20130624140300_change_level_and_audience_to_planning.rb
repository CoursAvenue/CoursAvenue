class ChangeLevelAndAudienceToPlanning < ActiveRecord::Migration
  def up
    create_table :levels_plannings, :id => false do |t|
      t.references :level, :planning
    end
    add_index :levels_plannings, [:planning_id, :level_id]

    create_table :audiences_plannings, :id => false do |t|
      t.references :planning, :audience
    end
    add_index :audiences_plannings, [:audience_id, :planning_id]

    bar = ProgressBar.new( Course.count + Place.count )

    # Affecting audience and levels to course
    Course.all.each do |course|
      course.plannings.each do |planning|
        planning.levels    = course.levels
        planning.audiences = course.audiences
        planning.save
      end
      bar.increment! 1
    end

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


    drop_table :courses_levels
    drop_table :audiences_courses
  end

  def down
  end
end
