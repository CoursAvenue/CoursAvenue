class CreatePriceGroupForExistingCourses < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Course.count
    Course.find_each(batch_size: 100) do |course|
      bar.increment!
      next if course.is_open?
      price_group        = PriceGroup.new structure: course.structure, name: course.name, course_type: course.type
      course_prices      = Price.where(course_id: course.id)
      price_group.prices = course_prices
      saved              = price_group.save
      puts "#{course.structure.slug}/#{course.slug}" unless saved
      course.price_group = price_group
      course.delay.save(validate: false)
      # GC.start
    end
  end
end
