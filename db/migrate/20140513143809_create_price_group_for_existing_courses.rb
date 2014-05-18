class CreatePriceGroupForExistingCourses < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Course.count
    i = 0
    Course.find_each(batch_size: 100) do |course|
      i += 1
      bar.increment!
      next if course.is_open?
      price_group        = PriceGroup.new structure: course.structure, name: course.name, course_type: course.type
      course_prices      = Price.where(course_id: course.id)
      saved              = price_group.save
      puts "#{course.structure.slug}/#{course.slug}" unless saved
      course_prices.map { |price| price.update_column :price_group_id, price_group.id}
      course.update_column :price_group_id, price_group.id
      GC.start if i % 50 == 0
    end
  end

  def down
  end
end
