# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :participation do
    user
    planning
    nb_adults 1
    nb_kids   0
    factory :participation_for_kid_and_adult do
      participation_for 'participations.for.kids_and_adults'
      nb_adults         1
      nb_kids           1
    end
  end
end
