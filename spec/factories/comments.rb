# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment_review, class: 'Comment::Review'  do
    commentable { FactoryGirl.create(:structure) }
    type        'Comment::Review'
    user
    rating      4
    title       { Faker::Lorem.sentence(4) }
    status      'accepted'


    after(:build) do |comment|
      comment.subjects << Subject.at_depth(2).first
    end

    # Comment contact
    author_name { Faker::Name.name }
    email       { Faker::Internet.email }

    # Comment content
    course_name { Faker::Lorem.sentence(4) }
    content     { Faker::Lorem.sentence(40) }
    # rating          [1,2,3,4,5].sample

    factory :accepted_comment do
      status 'accepted'
    end

  end
end
