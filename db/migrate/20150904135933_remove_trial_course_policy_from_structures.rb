class RemoveTrialCoursePolicyFromStructures < ActiveRecord::Migration
  def change
    remove_column :structures, :trial_courses_policy
  end
end
