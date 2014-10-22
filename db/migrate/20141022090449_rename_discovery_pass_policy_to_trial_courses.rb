class RenameDiscoveryPassPolicyToTrialCourses < ActiveRecord::Migration
  def change
    rename_column :structures, :discovery_pass_policy, :trial_courses_policy
    rename_column :plannings, :available_in_discovery_pass, :is_open_for_trial
    rename_column :courses, :available_in_discovery_pass, :is_open_for_trial
  end
end
