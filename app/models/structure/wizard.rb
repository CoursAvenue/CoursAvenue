# encoding: utf-8
class Structure::Wizard < ActiveHash::Base

  self.data = [
    {
        id: 1,
        name: 'wizard.description',
        partial: 'pro/structures/wizards/description',
        show_save: true,
        completed?: lambda {|structure| structure.description.present? }
    },
    {
        id: 2,
        name: 'wizard.logo',
        partial: 'pro/structures/wizards/logo',
        show_save: true,
        completed?: lambda {|structure| structure.logo? }
    },
    # {
    #     id: 3,
    #     name: 'wizard.coordonates',
    #     partial: 'pro/structures/wizards/coordonates',
    #     show_save: true,
    #     completed?: lambda {|structure| structure.phone_numbers.any? or structure.contact_email.present? }
    # },
    {
        id: 3,
        name: 'wizard.places',
        partial: 'pro/structures/wizards/places',
        show_save: true,
        completed?: lambda {|structure| structure.has_only_one_place? or structure.places.count > 1 }
    },
    {
        id: 4,
        name: 'wizard.recommendations',
        partial: 'pro/structures/wizards/recommendations',
        show_save: true,
        completed?: lambda {|structure| structure.comments.any? or structure.comment_notifications.any? }
    },
    {
        id: 5,
        name: 'wizard.widget_status',
        partial: 'pro/structures/wizards/widget_status',
        show_save: false,
        completed?: lambda {|structure| structure.comments_count < 5 or (structure.comments_count >= 5 and !structure.widget_status.blank?) }
    },
    {
        id: 6,
        name: 'wizard.widget_url',
        partial: 'pro/structures/wizards/widget_url',
        show_save: true,
        completed?: lambda {|structure| structure.widget_url.present? or (structure.comments_count < 5 or (structure.comments_count > 5 and !structure.has_installed_widget?)) }
    }
  ]
end

