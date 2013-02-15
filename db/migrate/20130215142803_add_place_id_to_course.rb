class AddPlaceIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :place_id, :integer
    add_index  :courses, :place_id
  end
end
