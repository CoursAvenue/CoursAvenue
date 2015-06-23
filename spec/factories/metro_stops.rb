FactoryGirl.define do
  factory :metro_stop, class: 'Metro::Stop' do
    name      'Faidherbe-Chaligny'
    latitude  2.3842745805324
    longitude 48.8502384503522

    trait :bastille do
      name      'Bastille'
      latitude  2.36918060506559
      longitude 48.8528417309667
    end
  end
end
