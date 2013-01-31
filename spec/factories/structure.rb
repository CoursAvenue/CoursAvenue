# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :structure do
    name { Forgery::Name.full_name + ' institute' }
  end
end
