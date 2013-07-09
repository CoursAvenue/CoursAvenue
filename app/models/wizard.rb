class Wizard < ActiveHash::Base

  self.data = [
    {
        id: 1,
        name: 'wizard.website',
        partial: 'wizards/website',
        completed?: lambda {|structure| structure.website.present? }
    },
    {
        id: 2,
        name: 'wizard.facebook',
        partial: 'wizards/facebook',
        completed?: lambda {|structure| structure.facebook_url.present? }
    },
    {
        id: 3,
        name: 'wizard.admin_name',
        partial: 'wizards/admin_name',
        completed?: lambda {|structure| structure.main_contact.name.present? }
    },
    {
        id: 4,
        name: 'wizard.admin_phone',
        partial: 'wizards/contact_phone',
        completed?: lambda {|structure| structure.main_contact.phone_number.present? }
    },
    {
        id: 5,
        name: 'wizard.structure_type',
        partial: 'wizards/structure_type',
        completed?: lambda {|structure| structure.structure_type.present? }
     }
  ]
end

