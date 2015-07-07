FactoryGirl.define do
  factory :guide_question, :class => 'Guide::Question' do
    # guide nil
    ponderation 1
    content Faker::Lorem.sentence
  end
end
