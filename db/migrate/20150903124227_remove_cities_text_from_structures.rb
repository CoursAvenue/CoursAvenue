class RemoveCitiesTextFromStructures < ActiveRecord::Migration
  def change
    remove_column :structures, :cities_text
  end
end
