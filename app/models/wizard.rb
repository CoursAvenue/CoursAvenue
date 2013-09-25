# encoding: utf-8
class Wizard < ActiveHash::Base

  self.data = [
    {
        id: 1,
        name: 'wizard.description',
        partial: 'wizards/description',
        show_save: true,
        completed?: lambda {|structure| structure.description.present? }
    },
    {
        id: 2,
        name: 'wizard.logo',
        partial: 'wizards/logo',
        show_save: true,
        completed?: lambda {|structure| structure.logo? }
    },
    {
        id: 3,
        name: 'wizard.places',
        partial: 'wizards/places',
        show_save: true,
        completed?: lambda {|structure| structure.has_only_one_place? or structure.places.count > 1 }
    },
    {
        id: 4,
        name: 'wizard.recommendations',
        partial: 'wizards/recommendations',
        show_save: true,
        completed?: lambda {|structure| structure.comments.any? or structure.students.any? }
    },
    {
        id: 5,
        name: 'wizard.widget_status',
        partial: 'wizards/widget_status',
        show_save: false,
        completed?: lambda {|structure| structure.comments_count < 5 or (structure.comments_count > 5 and !structure.widget_status.nil?) }
    }
    # {
    #     id: 1,
    #     name: 'wizard.website',
    #     partial: 'wizards/website',
    #     completed?: lambda {|structure| structure.no_website || structure.website.present? }
    # },
    # {
    #     id: 2,
    #     name: 'wizard.facebook',
    #     partial: 'wizards/facebook',
    #     completed?: lambda {|structure| structure.no_facebook || structure.facebook_url.present? }
    # },
    # {
    #     id: 3,
    #     name: 'wizard.admin_name',
    #     partial: 'wizards/admin_name',
    #     completed?: lambda {|structure| structure.main_contact.name.present? }
    # },
    # {
    #     id: 4,
    #     name: 'wizard.admin_phone',
    #     partial: 'wizards/contact_phone',
    #     completed?: lambda {|structure| structure.main_contact.phone_number.present? || structure.main_contact.mobile_phone_number.present? }
    # },
    # {
    #     id: 5,
    #     name: 'wizard.structure_type',
    #     partial: 'wizards/structure_type',
    #     completed?: lambda {|structure| structure.structure_type.present? }
    #  }
  ]
end

