class AddCommonPriceToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :common_price, :float

    bar = ProgressBar.new Course::Open.count
    Course::Open.find_each do |course|
      bar.increment!
      structure           = course.structure
      count               = structure.prices.individual.count
      all_amount          = structure.prices.individual.map(&:amount).reduce(&:+)
      if all_amount
        course.common_price = (all_amount / count).to_i
        course.save
      end
    end
  end
end
