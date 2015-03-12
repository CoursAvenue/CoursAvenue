class AddAssociatedZipCodesToCities < ActiveRecord::Migration
  def change
    add_column :cities, :meta_data, :hstore
  end
end
