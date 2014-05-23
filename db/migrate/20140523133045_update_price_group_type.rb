class UpdatePriceGroupType < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Course::Private.count
    Course::Private.find_each do |course|
      bar.increment!
      next if course.price_group.nil?
      course.price_group.update_column :course_type, 'Course::Private'
    end
  end
end
