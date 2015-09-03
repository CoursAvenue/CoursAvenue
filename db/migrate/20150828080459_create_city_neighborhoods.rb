class CreateCityNeighborhoods < ActiveRecord::Migration
  def up
    create_table :city_neighborhoods do |t|
      t.string     :name
      t.string     :image
      t.float      :latitude
      t.float      :longitude
      t.string     :slug
      t.references :city

      t.timestamps
    end
    add_index :city_neighborhoods, :city_id
    add_index :city_neighborhoods, :slug
  end
  def down
    drop_table :city_neighborhoods
  end
end
