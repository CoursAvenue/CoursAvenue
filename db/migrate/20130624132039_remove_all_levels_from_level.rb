class RemoveAllLevelsFromLevel < ActiveRecord::Migration
  def up
    all_levels = [Level.beginner, Level.intermediate, Level.confirmed]
    bar = ProgressBar.new( Course.count )
    Course.joins{levels}.where{levels.name == 'level.all'}.readonly(false).all.each do |course|
      course.levels = all_levels
      course.save
      bar.increment! 1
    end
    Level.where(name: 'level.all').first.destroy
  end

  def down
    Level.create(name: 'level.all')
  end
end
