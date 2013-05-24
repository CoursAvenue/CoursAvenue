# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    content         Forgery(:lorem_ipsum).words(8)
    author_name     Forgery::Name.full_name
    rating          [1,2,3,4,5].sample

    factory :course_comment do
      commentable_type "Course"
    end

    factory :structure_comment do
      commentable_type "Structure"
    end
  end
end
