class AddCLogoToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :c_logo, :string
    add_column :structures, :c_sleeping_logo, :string
  end
end
