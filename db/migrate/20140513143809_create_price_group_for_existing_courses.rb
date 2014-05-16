class CreatePriceGroupForExistingCourses < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Course.count
    Course.find_each(batch_size: 100) do |course|
      bar.increment!
      next if course.is_open?
      create_price_group(course)
      GC.start
    end
  end

  def down
  end

  def create_price_group(course)
    price_group        = PriceGroup.new structure: course.structure, name: course.name, course_type: course.type
    course_prices      = Price.where(course_id: course.id)
    saved              = price_group.save
    course_prices.map { |price| price.update_column :price_group, price_group.id}
    puts "#{course.structure.slug}/#{course.slug}" unless saved
    course.price_group = price_group
    course.delay.save(validate: false)
  end
  handle_asynchronously :create_price_group
end
