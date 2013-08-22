# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    city
    latitude          48.8592
    longitude         2.3417

    name              Forgery::Name.full_name + ' place'
    street            Forgery(:address).street_address
    zip_code          75014
  end
end
