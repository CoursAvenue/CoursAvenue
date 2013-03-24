# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :place do
    city FactoryGirl.create(:city_paris)

    latitude          48.8592
    longitude         2.3417

    name    'A place'
    street  'a street'
    zip_code 75000
    info    'info'
    nb_room  1
    has_handicap_access false
    contact_name        'MyString'
    contact_phone       'MyString'
    contact_email       'MyString'
  end
end
