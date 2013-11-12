class AddRadiusForTeachesAtHome < ActiveRecord::Migration
  def change
    add_column :structures, :teaches_at_home_radius, :integer
  end
end
