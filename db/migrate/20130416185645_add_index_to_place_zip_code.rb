class AddIndexToPlaceZipCode < ActiveRecord::Migration
  def change
    add_index :places, :zip_code
  end
end
