# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :price, class: 'Price::BookTicket' do
    type 'Price::BookTicket'
    amount 200
    number 1

    factory :book_ticket do
      type 'Price::BookTicket'
      number 10
    end

    factory :price_subscription, class: 'Price::Subscription' do
      type 'Price::Subscription'
      libelle 'prices.subscription.annual'
    end

    factory :registration, class: 'Price::Registration' do
      type 'Price::Registration'
    end

    factory :discount, class: 'Price::Discount' do
      type 'Price::Discount'
    end

    factory :with_promo do
      libelle 'prices.annual'
      promo_amount 123
    end

  end
end
