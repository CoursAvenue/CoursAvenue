class CreateMetroStops < ActiveRecord::Migration
  def change
    create_table :metro_stops do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :slug

      t.timestamps
    end
  end
end
