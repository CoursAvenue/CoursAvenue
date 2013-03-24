# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :room do
    place FactoryGirl.create(:place)
    # association :place

    name   'Main room'
    surface 32
  end
end
