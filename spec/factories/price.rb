# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :price do
    amount Forgery(:monetary).money
    type 'Price::BookTicket'
    number 1

    factory :book_ticket do
      type 'Price::BookTicket'
      number 10
    end

    factory :subscription do
      type 'Price::Subscription'
      libelle 'prices.subscription.annual'
    end

    factory :registration do
      type 'Price::Registration'
    end

    factory :discount do
      type 'Price::Discount'
    end

    factory :individual_price do
      nb_courses 35
    end

    factory :with_promo do
      libelle 'prices.annual'
      nb_courses 35
      promo_amount 123
    end

  end
end
