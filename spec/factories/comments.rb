# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    commentable {FactoryGirl.create(:structure)}

    # Comment contact
    author_name     Forgery::Name.full_name
    sequence :email do |n|
      "person#{n}@example.com"
    end


    # Comment content
    course_name     Forgery(:lorem_ipsum).words(4)
    content         Forgery(:lorem_ipsum).words(8)
    # rating          [1,2,3,4,5].sample

    factory :accepted_comment do
      status 'accepted'
    end
  end
end
