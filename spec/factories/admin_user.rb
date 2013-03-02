# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :admin_user do

    association :structure

    firstname   'Timoté'
    lastname    'Gaélique'
    email       'timo@gael.com'
    password    'password'
end
