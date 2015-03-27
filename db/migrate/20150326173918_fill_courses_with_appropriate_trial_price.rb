
class FillCoursesWithAppropriateTrialPrice < ActiveRecord::Migration
  def up
    # First remove all course_id from prices to prevent from prices that are related to price_group
    # and not course
    Price.update_all course_id: nil

    puts 'Lessons... '
    bar = ProgressBar.new Course::Lesson.count
    Course::Lesson.find_each do |course|
      bar.increment!
      course.delay.migrate_prices
    end

    puts 'Privates...'
    bar = ProgressBar.new Course::Private.count
    Course::Private.find_each do |course|
      bar.increment!
      course.delay.migrate_prices
    end

    puts 'Trainings...'
    bar = ProgressBar.new Course::Training.count
    Course::Training.find_each do |course|
      bar.increment!
      next if course.price_group.nil?
      course.delay.migrate_prices
    end
  end

  def down
  end
end
