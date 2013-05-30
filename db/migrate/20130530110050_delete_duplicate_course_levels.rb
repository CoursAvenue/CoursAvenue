class DeleteDuplicateCourseLevels < ActiveRecord::Migration
  def up
    bar = ProgressBar.new( Course.count )
    Course.all.each do |course|
      levels_count = course.levels.count
      if levels_count > 1
        if levels_count > (new_levels = course.levels.uniq).length
          course.levels = [Level.first]
          course.save
          course.levels = new_levels
          course.save
        end
      end
      bar.increment! 1
    end
  end

  def down
  end
end
