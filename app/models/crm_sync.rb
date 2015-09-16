# encoding: utf-8
# Updates to current CRM (CloseIO)
class CrmSync

  def self.update(structure)
    admin = structure.admin
    if admin.nil?
      results = CrmSync.create_sleeping_contact(structure)
    else
      if structure.close_io_lead_id.present?
        existing_lead = self.client.find_lead structure.close_io_lead_id
      else
        existing_lead = self.client.list_leads("email:\"#{structure.admin.email.downcase.strip}\"")['data'].first
      end
      if existing_lead and existing_lead[:contacts]
        existing_contact    = existing_lead[:contacts].detect{ |contact_data| contact_data[:emails].any? && contact_data[:emails].first[:email] == structure.admin.email.strip.downcase }
        existing_contact_id = existing_contact[:id] if existing_contact
        data                = self.data_for_structure(structure, existing_contact_id)
        results             = self.client.update_lead(existing_lead['id'], data)
        structure.update_column :meta_data, structure[:meta_data].merge('close_io_lead_id' => results[:id])
      else
        results = self.client.create_lead(self.data_for_structure(structure))
        structure.update_column :meta_data, structure[:meta_data].merge('close_io_lead_id' => results[:id])
      end
    end
    # results can be nil...
    if results and ((results['errors'] and results['errors'].any?) or (results['field-errors'] and results['field-errors'].any?))
      structure_hash_info = { structure_slug: structure.slug, structure_name: structure.name, website: structure.website }
      Bugsnag.notify(RuntimeError.new("CrmSync error"), results.merge(structure_hash_info))
    end
    structure.unlock_crm!
    results
  end

  def self.destroy(email)
    leads = self.client.list_leads("email:\"#{email}\"")['data']
    leads.each do |lead|
      self.client.delete_lead(lead['id'])
    end
  end

  private

  def self.client
    CloseioFactory.client
  end

  def self.create_sleeping_contact(structure)
    return nil if structure.contact_email.blank?
    if structure.close_io_lead_id.present?
      existing_lead = self.client.find_lead structure.close_io_lead_id
    else
      existing_lead = self.client.list_leads("email:\"#{structure.contact_email.downcase}\"")['data'].first
    end
    if existing_lead and existing_lead[:contacts]
      existing_contact    = existing_lead[:contacts].detect{ |contact_data| contact_data[:emails].any? && contact_data[:emails].first[:email] == structure.contact_email.downcase }
      existing_contact_id = existing_contact[:id] if existing_contact
      data                = self.data_for_sleeping_structure(structure, existing_contact_id)
      results = self.client.update_lead(existing_lead['id'], data)
      structure.update_column :meta_data, structure[:meta_data].merge('close_io_lead_id' => results[:id])
    else
      results = self.client.create_lead(self.data_for_sleeping_structure(structure))
      structure.update_column :meta_data, structure[:meta_data].merge('close_io_lead_id' => results[:id])
    end
    results
  end

  def self.place_addresses_from_structure(structure)
    places_address = [{ address_1: structure.street, zipcode: structure.zip_code, city: structure.city.try(:name), country: 'FR' }]
    places_address += structure.places.map{ |place| { address_1: place.street, zipcode: place.zip_code, city: place.city.name, country: 'FR' }}
    places_address.uniq
  end

  def self.data_for_sleeping_structure(structure, existing_contact_id=nil)
    email_addresses = [ { email: structure.contact_email.downcase, type: 'office' } ]
    if structure.other_emails
      structure.other_emails.split(';').each do |email|
        email_addresses << { email: email.downcase.strip, type: 'office' }
      end
    end
    contact = { name: structure.name,
                phones: structure.phone_numbers.uniq.map{|pn| { phone: pn.international_format, type: 'office' } }.reject{|hash| hash[:phone].length < 10 or hash[:phone].length > 15},
                emails: email_addresses }
    contact[:id] = existing_contact_id if existing_contact_id
    {
      name:      structure.name,
      addresses: self.place_addresses_from_structure(structure),
      url:       structure.website,
      status:    self.structure_status(structure),
      custom:    self.structure_custom_datas(structure),
      contacts:  [contact]
    }
  end

  def self.data_for_structure(structure, existing_contact_id=nil)
    admin = structure.admin
    contact = { name:   structure.name,
                phones: structure.phone_numbers.uniq.map{|pn| { phone: pn.international_format, type: 'office' } }.reject{|hash| hash[:phone].length < 10 or hash[:phone].length > 15},
                emails: [{ email: admin.email.downcase.strip, type: 'office' }]
              }
    contact[:id] = existing_contact_id if existing_contact_id
    {
      name:      structure.name,
      addresses: self.place_addresses_from_structure(structure),
      url:       structure.website,
      status:    self.structure_status(structure),
      custom:    self.structure_custom_datas(structure),
      contacts:  [contact]
    }
  end

  def self.structure_custom_datas(structure)
    admin = structure.admin
    custom_datas = {}
    custom_datas[:facebook_url]                     = structure.facebook_url if structure.facebook_url.present?
    custom_datas['1. Profil public']                = Rails.application.routes.url_helpers.structure_url(structure, subdomain: 'www', host: 'coursavenue.com')
    custom_datas['2. Profil privée']                = Rails.application.routes.url_helpers.pro_structure_url(structure, subdomain: 'pro', host: 'coursavenue.com')
    custom_datas["Nbre avis"]                       = structure.comments_count if structure.comments_count
    custom_datas["Nbre de cours actifs"]            = structure.plannings.future.group_by(&:course_id).length
    custom_datas["Nbre de discussions"]             = structure.mailbox.conversations.count if structure.mailbox
    custom_datas["Nbre de photos/vidéos"]           = structure.medias.count
    custom_datas["Dernière connexion à son profil"] = I18n.l(admin.current_sign_in_at, format: :date_short_en) if admin and admin.current_sign_in_at
    custom_datas["Disciplines 1"]                   = structure.subjects.at_depth(0).uniq.map(&:name).join('; ') if structure.subjects.at_depth(0).any?
    custom_datas["Disciplines 3"]                   = structure.subjects.at_depth(2).uniq.map(&:name).join('; ') if structure.subjects.at_depth(2).any?
    custom_datas["Premium ?"]                       = (structure.premium? ? 'Oui' : 'Non')
    custom_datas
  end

  def self.structure_status(structure)
    if structure.admin.nil?
      "Dormant"
    elsif structure.admin && !structure.admin.confirmed?
      'Non actif'
    elsif structure.plannings.future.empty?
      'Incomplet'
    elsif structure.comments_count.nil? or structure.comments_count == 0
      'Sans avis'
    elsif structure.comments_count and structure.comments_count > 0 and structure.plannings.future.any?
      'Star'
    end
  end

  def self.structure_status_for_intercom(structure)
    if structure.admin.nil?
      "Dormant"
    elsif structure.admin && !structure.admin.confirmed?
      'Non actif'
    elsif structure.description.nil? or structure.description.length < 2
      'Sans description'
    elsif structure.plannings.future.empty?
      'Incomplet'
    elsif structure.comments_count.nil? or structure.comments_count == 0
      'Sans avis'
    elsif structure.comments_count and structure.comments_count > 0 and structure.plannings.future.any?
      'Star'
    end
  end
end
