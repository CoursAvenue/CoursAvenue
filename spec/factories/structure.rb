# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :structure do
    name               { Faker::Name.name + rand.to_s }

    street             'Paris'
    zip_code           '75014'
    latitude           48.8592
    longitude          2.3417

    structure_type     Structure::STRUCTURE_TYPES.sample

    subjects { [ FactoryGirl.create(:subject), FactoryGirl.create(:subject_with_grand_parent) ] }

    comments_count 0
    after(:build) do |structure|
      structure.places   << FactoryGirl.build(:place, structure: structure)
      structure.save
    end

    factory :structure_with_admin do
      after(:build) do |structure|
        structure.admin = FactoryGirl.build(:admin)
      end
    end

    factory :structure_with_place do
      after(:create) do |structure|
        structure.places << FactoryGirl.build(:place)
        structure.save
      end
    end

    factory :structure_with_multiple_place do
      after(:create) do |structure|
        structure.places << FactoryGirl.build(:place)
        structure.places << FactoryGirl.build(:place)
        structure.save
      end
    end
    factory :structure_with_user_profiles do
      after(:create) do |structure|
        3.times { structure.user_profiles << FactoryGirl.build(:user_profile) }
        structure.save
      end
    end
    factory :structure_with_user_profiles_with_tags do
      after(:create) do |structure|
        3.times { structure.user_profiles << FactoryGirl.build(:user_profile_with_tags) }
        structure.save
      end
    end

    factory :sleeping_structure do
      after(:build) do |structure|
        structure.admin = nil
      end
    end

    factory :independant_structure do
      structure_type 'structures.independant'
    end

    trait :with_contact_email do
      contact_email { Faker::Internet.email }
    end

    trait :with_contact_mobile_phone do
      contact_mobile_phone '0601928374'
    end

    trait :with_contact_phone do
      contact_phone '0101928374'
    end

    trait :enabled do
      enabled true
    end

    trait :disabled do
      enabled false
    end

    trait :deleted do
      deleted_at { 1.hour.from_now }
    end
  end
end
