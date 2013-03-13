# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :price do
    amount 1241

    factory :annual_price do
      libelle 'prices.annual'
      nb_course 35
    end

  end
end
