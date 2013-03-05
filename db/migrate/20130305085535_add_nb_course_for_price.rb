class AddNbCourseForPrice < ActiveRecord::Migration
  def up
    add_column :prices, :nb_course, :integer
    Price.all.each do |price|
      price.nb_course = case price.libelle
      when 'prices.free'
        1
      when 'prices.individual_course'
        1
      when 'prices.two_lesson_per_week_package'
        2
      when 'prices.annual'
        35
      when 'prices.semester'
        17
      when 'prices.trimester'
        11
      when 'prices.month'
        4
      when 'prices.trial_lesson'
        1
      when 'prices.training'
        1
      else 0
      end
      price.save
    end
  end

  def down
    remove_column :prices, :nb_course
  end
end
