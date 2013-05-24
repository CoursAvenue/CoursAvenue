# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :admin do

    structure

    name     Forgery::Name.full_name
    sequence :email do |n|
      "person#{n}@example.com"
    end
    confirmed_at Date.today
    # password    { Forgery(:basic).password(:at_least => 6, :at_most => 10) }
  end
end
