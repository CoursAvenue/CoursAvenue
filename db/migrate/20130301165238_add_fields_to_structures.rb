class AddFieldsToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :address, :string
    add_column :structures, :zip_code, :string
    add_column :structures, :city_name, :string
  end
end
