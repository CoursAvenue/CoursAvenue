FactoryGirl.define do
  factory :guide_question, :class => 'Guide::Question' do
    # guide nil
    ponderation 1
    content { Faker::Lorem.sentence }

    trait :with_answers do
      after(:create) do |question|
        3.times { question.answers << FactoryGirl.create(:guide_answer, question: question) }
      end
    end

  end
end
