# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :structure_at_paris, class: Structure do
    name { Forgery::Name.full_name + ' institute' }
    association :city, factory: :city_paris
  end

  factory :structure_at_nice, class: Structure do
    name { Forgery::Name.full_name + ' institute' }
    association :city, factory: :city_nice
  end
end
