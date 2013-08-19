class RemoveUselessFieldOfLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :description
    remove_column :locations, :info
    remove_column :locations, :has_handicap_access
    remove_column :locations, :has_cloackroom
    remove_column :locations, :has_internet
    remove_column :locations, :has_air_conditioning
    remove_column :locations, :has_swimming_pool
    remove_column :locations, :has_free_parking
    remove_column :locations, :has_jacuzzi
    remove_column :locations, :has_sauna
    remove_column :locations, :has_daylight
    remove_column :locations, :nb_room
    remove_column :locations, :parent_subjects_string
    remove_column :locations, :subjects_string
  end

  def down
    add_column :locations, :description,           :string
    add_column :locations, :info,                  :string
    add_column :locations, :has_handicap_access,   :string
    add_column :locations, :has_cloackroom,        :string
    add_column :locations, :has_internet,          :string
    add_column :locations, :has_air_conditioning,  :string
    add_column :locations, :has_swimming_pool,     :string
    add_column :locations, :has_free_parking,      :string
    add_column :locations, :has_jacuzzi,           :string
    add_column :locations, :has_sauna,             :string
    add_column :locations, :has_daylight,          :string
    add_column :locations, :nb_room,               :string
    add_column :locations, :parent_subjects_string,:string
    add_column :locations, :subjects_string,       :string
  end
end
