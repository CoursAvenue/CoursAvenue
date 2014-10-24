class RenameDiscoveryPassPolicyToTrialCourses < ActiveRecord::Migration
  def up
    rename_column :structures, :discovery_pass_policy, :trial_courses_policy
    rename_column :courses, :available_in_discovery_pass, :is_open_for_trial
    remove_column :plannings, :available_in_discovery_pass
  end

  def down
    rename_column :structures, :trial_courses_policy, :discovery_pass_policy
    rename_column :courses, :is_open_for_trial, :available_in_discovery_pass
    add_column :plannings, :available_in_discovery_pass, :boolean
  end
end
