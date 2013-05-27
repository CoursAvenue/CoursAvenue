# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :price do
    amount 1241
    libelle 'prices.individual_course'

    factory :annual_price do
      libelle 'prices.annual'
      nb_courses 35
    end

    factory :individual_price do
      libelle 'prices.individual_course'
      nb_courses 35
    end

    factory :with_promo do
      libelle 'prices.annual'
      nb_courses 35
      promo_amount 123
    end

  end
end
