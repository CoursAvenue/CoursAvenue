class AddDescriptionToMetroStops < ActiveRecord::Migration
  def change
    add_column :metro_stops, :description, :string
  end
end
