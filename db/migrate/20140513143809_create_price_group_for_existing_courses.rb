class CreatePriceGroupForExistingCourses < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Course.count
    Course.find_each do |course|
      bar.increment!
      price_group        = PriceGroup.new structure: course.structure, name: course.name, course_type: course.type
      course_prices      = Price.where(course_id: course.id)
      price_group.prices = course_prices
      saved              = price_group.save
      puts "#{course.structure.slug}/#{course.slug}" unless saved
      course.price_group = price_group
      course.save(validate: false)
    end
  end
end
