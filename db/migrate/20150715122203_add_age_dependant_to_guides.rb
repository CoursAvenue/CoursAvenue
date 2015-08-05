class AddAgeDependantToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :age_dependant, :boolean
  end
end
