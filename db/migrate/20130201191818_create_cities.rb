class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string     :name
      t.string     :short_name
      t.attachment :no_result_image
      t.timestamps
    end
    add_index :cities, :short_name
    cities = ['Paris', 'Bordeaux', 'Lille', 'Lyon', 'Marseille', 'Montpellier', 'Nantes', 'Nice', 'Strasbourg', 'Toulouse']
    cities.each do |city_name|
      City.create(name: city_name, short_name: city_name.downcase)
    end
  end
end
