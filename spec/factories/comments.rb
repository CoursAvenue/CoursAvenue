# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    commentable {FactoryGirl.create(:structure)}
    user

    # Comment contact
    author_name     Faker::Name.name
    sequence :email do |n|
      "person#{n}@example.com"
    end


    # Comment content
    course_name       Faker::Lorem.sentence(4)
    content           Faker::Lorem.sentence(8)
    # rating          [1,2,3,4,5].sample

    factory :accepted_comment do
      status 'accepted'
    end
  end
end
