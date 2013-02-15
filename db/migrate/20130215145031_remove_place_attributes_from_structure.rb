class RemovePlaceAttributesFromStructure < ActiveRecord::Migration
  def up
    remove_column :structures, :city_id
    remove_column :structures, :place_name
    remove_column :structures, :street
    remove_column :structures, :adress_info
    remove_column :structures, :zip_code
    remove_column :structures, :has_handicap_access
    remove_column :structures, :nb_room
    remove_column :structures, :latitude
    remove_column :structures, :longitude
    remove_column :structures, :gmaps

  end
  def down
    add_column :structures, :city_id, :string
    add_column :structures, :place_name, :string
    add_column :structures, :street, :string
    add_column :structures, :adress_info, :string
    add_column :structures, :zip_code, :string
    add_column :structures, :has_handicap_access, :boolean
    add_column :structures, :nb_room, :integer
    add_column :structures, :latitude, :float
    add_column :structures, :longitude, :float
    add_column :structures, :gmaps, :boolean

  end
end
