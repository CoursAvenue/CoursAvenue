class MergeLevels < ActiveRecord::Migration
  def up
    average_level      = Level.where(name: 'level.average').first
    intermediate_level = Level.where(name: 'level.intermediate').first
    average_level.courses.each do |course|
      course.levels << intermediate_level
      course.levels.delete average_level
      course.save
    end
    average_level.delete

    advanced_level  = Level.where(name: 'level.advanced').first
    confirmed_level = Level.where(name: 'level.confirmed').first
    confirmed_level.courses.each do |course|
      course.levels << confirmed_level
      course.levels.delete advanced_level
      course.save
    end
    advanced_level.delete
  end

  def down
  end
end
