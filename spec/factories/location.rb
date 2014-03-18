# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    city
    latitude          48.8592
    longitude         2.3417

    name              { Faker::Name.name + ' place' }
    street            'Paris'
    zip_code          75014
  end
end
