class AddCitiesTextToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :cities_text, :string
  end
end
