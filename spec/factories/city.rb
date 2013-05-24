#-*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :city do
    name              "Paris"
    iso_code          "FR"
    zip_code          75000
    region_name       "Île-de-France"
    region_code       "A8"
    department_name   "Paris"
    department_code   "75"
    commune_name      "Paris"
    commune_code      "751"
    latitude          48.8592
    longitude         2.3417
    acuracy           5
  end
end
