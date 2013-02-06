class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string     :name
      t.attachment :no_result_image
      t.timestamps
    end
    add_column :cities, :slug, :string
    add_index  :cities, :slug, unique: true

    cities = ['Paris', 'Bordeaux', 'Lille', 'Lyon', 'Marseille', 'Montpellier', 'Nantes', 'Nice', 'Strasbourg', 'Toulouse']
    cities.each do |city_name|
      City.create(name: city_name)
    end

  end
end
