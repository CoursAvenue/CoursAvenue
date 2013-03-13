# encoding: UTF-8
class UpdatePlaceCities < ActiveRecord::Migration
  def up
    City.create(
              name: "Paris",
          iso_code: "FR",
          zip_code: "75000",
       region_name: "Île-de-France",
       region_code: "A8",
   department_name: "Paris",
   department_code: "75",
      commune_name: "Paris",
      commune_code: "751",
          latitude: 48.8592,
         longitude: 2.3417,
           acuracy: 5
      )
    Place.all.each do |place|
      place_zip_code = place.zip_code
      place.city = City.where{zip_code == place_zip_code}.first
      place.save
    end
  end

  def down
  end
end
