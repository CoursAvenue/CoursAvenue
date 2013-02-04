# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :structure do
    name { Forgery::Name.full_name + ' institute' }
    association :city

    factory :structure_at_paris do
      association :nice
    end
  end
end
