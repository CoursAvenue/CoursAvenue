class MovePriceDetailsFromCourseToPriceGroup < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Course.where.not(price_details: nil).count
    Course.where.not(price_details: nil).find_each do |course|
      bar.increment!
      next if course.price_group.nil?
      course.price_group.update_column :details, course.price_details
    end
  end
end
