class AddAvailableInDiscoveryPassToCoursesAndPlannings < ActiveRecord::Migration
  def change
    add_column :courses, :available_in_discovery_pass, :boolean
    add_column :plannings, :available_in_discovery_pass, :boolean
  end
end
