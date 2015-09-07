class RemovePassionZipCodeFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :passion_city_id
    remove_column :users, :passion_zip_code
  end
end
