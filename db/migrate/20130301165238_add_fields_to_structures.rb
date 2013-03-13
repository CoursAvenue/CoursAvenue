class AddFieldsToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :street, :string
    add_column :structures, :zip_code, :string
    add_column :structures, :description, :text
  end
end
