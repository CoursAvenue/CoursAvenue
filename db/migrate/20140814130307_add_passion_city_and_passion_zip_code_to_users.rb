class AddPassionCityAndPassionZipCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :passion_city_id, :integer
    add_column :users, :passion_zip_code, :string
  end
end
