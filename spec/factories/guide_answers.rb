FactoryGirl.define do
  factory :guide_answer, :class => 'Guide::Answer' do
    # guide nil
    # guide_question nil
    content { Faker::Lorem.sentence }

    trait :with_subjects do
      subjects { [ FactoryGirl.create(:subject), FactoryGirl.create(:subject) ] }
    end
  end
end
