# encoding: utf-8
class User::Wizard < ActiveHash::Base

  self.data = [
    {
        id: 1,
        name: 'wizard.phone_number',
        partial: 'users/wizards/phone_number',
        show_save: true,
        completed?: lambda {|user| user.phone_number.present? }
    },
    {
        id: 2,
        name: 'wizard.birthdate',
        partial: 'users/wizards/birthdate',
        show_save: true,
        completed?: lambda {|user| user.birthdate.present? }
    },
    {
        id: 3,
        name: 'wizard.zip_code',
        partial: 'users/wizards/zip_code',
        show_save: true,
        completed?: lambda {|user| user.city.present? }
    }
  ]
end
