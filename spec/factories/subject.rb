# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :subject do
    name Forgery(:lorem_ipsum).words(2)
  end
end
