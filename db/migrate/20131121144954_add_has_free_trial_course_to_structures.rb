class AddHasFreeTrialCourseToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :has_free_trial_course, :boolean, default: false

    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      structure.update_column :has_free_trial_course, structure.prices.where{(type == 'Price::Trial') & ((amount == nil) | (amount == 0))}.any?
    end
  end
end
