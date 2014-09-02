# encoding: utf-8
# Updates to Highrise
class CrmSync

  def self.update(structure)
    admin          = structure.main_contact
    places_address = [{ street: structure.street, zip: structure.zip_code, location: 'Work', city: structure.city.name }]
    places_address += structure.places.map{ |place| { street: place.street, zip: place.zip_code, location: 'Work', city: place.city.name }}

    person = Highrise::Person.where(email: admin.email.downcase).first
    person.set_field_value('Disciplines 1'                  , structure.subjects.at_depth(0).uniq.map(&:name).join('; '))
    person.set_field_value('Disciplines 3'                  , structure.subjects.at_depth(2).uniq.map(&:name).join('; '))
    person.set_field_value('Premium ?'                      , ( structure.premium? ? 'Oui' : 'Non' ))
    person.set_field_value('Stats : # d’affichages'         , structure.impression_count(1000))
    person.set_field_value('Stats : # de vues'              , structure.view_count(1000))
    person.set_field_value('Stats : # de demandes d’info'   , admin.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).count)
    person.set_field_value("Stats : # d'actions"            , structure.action_count(1000))
    person.set_field_value('# de discussions'               , admin.mailbox.conversations.count)
    person.set_field_value("# d'avis"                       , structure.comments_count)
    person.set_field_value('# de cours actifs'              , structure.courses.select(&:is_published?).length)
    person.set_field_value('# de photos/vidéos'             , structure.medias.count)
    person.set_field_value('Dernière connexion à son profil', I18n.l(admin.last_sign_in_at, format: :date)) if admin.last_sign_in_at.present?
    person.set_field_value('ID'                             , "https://coursavenue1.highrisehq.com/people/#{person.id}")
    person.contact_data = {
      addresses: places_address.uniq,
      phone_numbers: structure.phone_numbers.map{ |phone_number| { number: phone_number.number, location: 'Work' } },
      web_addresses: [
        { url: Rails.application.routes.url_helpers.structure_url(structure, subdomain: 'www', host: 'coursavenue.com'), location: 'Work' },
        { url: Rails.application.routes.url_helpers.pro_structure_url(structure, subdomain: 'pro', host: 'coursavenue.com'), location: 'Work' },
        { url: structure.website, location: 'Work' }
      ]
    }
    unless person.save
      puts person.errors.full_messages
    end
  end

  def self.create_contact(structure)
    admin          = structure.main_contact
    person = Highrise::Person.new(name: structure.name,
                                  contact_data: {
                                    email_addresses: [ { address: admin.email.downcase } ]
                                  })
    puts "Creating #{admin.email.downcase} from #{structure.name}"
    if person.save
      self.update(structure)
    else
      puts person.errors.full_messages
    end
  end
end
