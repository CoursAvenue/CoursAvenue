# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :place do
    city
    structure
    latitude          48.8592
    longitude         2.3417

    name              { Faker::Name.name + ' place' }
    street            'Paris'
    zip_code          '75014'

    trait :not_parisian do
      zip_code '89100'
    end

    # after(:build) do |place|
    #   place.subjects << FactoryGirl.build(:subject)
    #   place.save
    # end
  end
end
