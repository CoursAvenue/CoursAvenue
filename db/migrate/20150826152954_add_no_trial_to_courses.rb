class AddNoTrialToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :no_trial, :boolean
  end
end
