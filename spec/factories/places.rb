# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :place do
    name "MyString"
    street "MyString"
    info "MyText"
    zip_code "MyString"
    has_handicap_access false
    nb_room 1
    contact_name "MyString"
    contact_phone "MyString"
    contact_email "MyString"
  end
end
