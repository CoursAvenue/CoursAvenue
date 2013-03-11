# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :admin_user do

    association :structure

    first_name   'Timoté'
    last_name    'Gaélique'
    email       'timo@gael.com'
    password    'password'
  end
end
