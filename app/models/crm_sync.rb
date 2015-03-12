# encoding: utf-8
# Updates to Highrise
class CrmSync

  def self.client
    Closeio::Client.new(ENV['CLOSE_IO_API_KEY'])
  end

  def self.update(structure)
    admin = structure.main_contact
    if admin.nil?
      results = CrmSync.create_sleeping_contact(structure)
    else
      existing_lead = self.client.list_leads("email:\"#{structure.main_contact.email.downcase}\"")['data'].first
      if existing_lead
        existing_contact = existing_lead[:contacts].detect{ |contact_data| contact_data[:emails].first[:email] == structure.main_contact.email.downcase }
        existing_contact_id = existing_contact[:id] if existing_contact
        data = self.data_for_structure(structure, existing_contact_id)
        results = self.client.update_lead(existing_lead['id'], data)
      else
        results = self.client.create_lead(self.data_for_structure(structure))
      end
    end
    if (results['errors'] and results['errors'].any?) or (results['field-errors'] and results['field-errors'].any?)
      structure_hash_info = { structure_slug: structure.slug, structure_name: structure.name }
      Bugsnag.notify(RuntimeError.new("CrmSync error"), results.merge(structure_hash_info))
    end
    results
  end

  def self.create_sleeping_contact(structure)
    return if structure.contact_email.blank?
    existing_lead = self.client.list_leads("email:\"#{structure.contact_email.downcase}\"")['data'].first
    if existing_lead
      existing_contact_id = existing_lead[:contacts].detect{ |contact_data| contact_data[:emails].first[:email] == structure.contact_email.downcase }[:id]
      data                = self.data_for_sleeping_structure(structure, existing_contact_id)
      self.client.update_lead(existing_lead['id'], data)
    else
      self.client.create_lead(self.data_for_sleeping_structure(structure))
    end

  end

  def self.place_addresses_from_structure(structure)
    places_address = [{ address_1: structure.street, zipcode: structure.zip_code, city: structure.city.name, country: 'FR' }]
    places_address += structure.places.map{ |place| { address_1: place.street, zipcode: place.zip_code, city: place.city.name, country: 'FR' }}
    places_address.uniq
  end

  def self.data_for_sleeping_structure(structure, existing_contact_id=nil)
    email_addresses = [ { email: structure.contact_email.downcase, type: 'office' } ]
    if structure.other_emails
      structure.other_emails.split(';').each do |email|
        email_addresses << { email: email.downcase, type: 'office' }
      end
    end
    contact = { name: structure.name,
                phones: structure.phone_numbers.uniq.map{|pn| { phone: pn.number, type: 'office' } },
                emails: email_addresses }
    contact[:id] = existing_contact_id if existing_contact_id
    {
      name: structure.name,
      addresses: self.place_addresses_from_structure(structure),
      url: structure.website,
      status: self.structure_status(structure),
      custom: self.structure_custom_datas(structure),
      contacts: [contact]
    }
  end

  def self.data_for_structure(structure, existing_contact_id=nil)
    admin = structure.main_contact
    contact = { name: structure.name,
                phones: structure.phone_numbers.uniq.map{|pn| { phone: pn.international_format, type: 'office' } }.reject{|hash| hash[:phone].length < 10},
                emails: [{ email: admin.email.downcase, type: 'office' }]
              }
    contact[:id] = existing_contact_id if existing_contact_id
    {
      name: structure.name,
      addresses: self.place_addresses_from_structure(structure),
      url: structure.website,
      status: self.structure_status(structure),
      custom: self.structure_custom_datas(structure),
      contacts: [contact]
    }
  end

  def self.structure_custom_datas(structure)
    admin = structure.main_contact
    custom_datas = {}
    custom_datas[:facebook_url] = structure.facebook_url if structure.facebook_url
    custom_datas['1. Profil public']                = Rails.application.routes.url_helpers.structure_url(structure, subdomain: 'www', host: 'coursavenue.com')
    custom_datas['2. Profil privée']                = Rails.application.routes.url_helpers.pro_structure_url(structure, subdomain: 'pro', host: 'coursavenue.com')
    custom_datas["Nbre avis"]                       = structure.comments_count if structure.comments_count
    custom_datas["Nbre de cours actifs"]            = structure.plannings.future.group_by(&:course_id).length
    custom_datas["Nbre de discussions"]             = structure.mailbox.conversations.count if structure.mailbox
    custom_datas["Nbre de photos/vidéos"]           = structure.medias.count
    custom_datas["Dernière connexion à son profil"] = I18n.l(admin.current_sign_in_at, format: :date_short_en) if admin and admin.current_sign_in_at
    custom_datas["Disciplines 1"]                   = structure.subjects.at_depth(0).uniq.map(&:name).join('; ')
    custom_datas["Disciplines 3"]                   = structure.subjects.at_depth(2).uniq.map(&:name).join('; ')
    custom_datas["JPO"]                             = (structure.courses.open_courses.any? ? 'Oui' : 'Non')
    custom_datas["Premium ?"]                       = (structure.premium? ? 'Oui' : 'Non')
    # "Stats : # d'actions" => ,
    # "Stats : # d’affichages" => ,
    # "Stats : # de demandes d’info" => ,
    # "Stats : # de vues" => ,
    custom_datas
  end

  def self.structure_status(structure)
    if structure.main_contact.nil?
      "Dormant"
    elsif structure.plannings.future.empty?
      'Incomplet'
    elsif structure.comments_count.nil? or structure.comments_count == 0
      'Sans avis'
    elsif structure.comments_count and structure.comments_count > 0 and structure.plannings.future.any?
      'Star'
    end
  end
end
