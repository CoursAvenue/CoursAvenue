class AddIndexOnZipCodeCity < ActiveRecord::Migration
  def change
    add_index :cities, :zip_code
    add_index :cities, :name
  end
end
