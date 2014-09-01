# encoding: utf-8
class NutshellUpdater

  @@nutshell = nil

  def self.nutshell
    if @@nutshell.nil?
      @@nutshell = NutshellCrm::Client.new "nicolas@coursavenue.com", "e9dd959a489948e664101c1e9f77fd5463032665"
    else
      @@nutshell
    end
  end

  def self.update(structure)
    if (admin = structure.main_contact)
      contacts = self.nutshell.search_by_email admin.email.downcase
      if contacts['contacts'].any?
        puts 'Updating contact'
        self.update_contact(structure)
      else
        puts 'Creating contact'
        self.create_contact(structure)
      end
    end
  end

  def self.merge_contacts(email)
    contacts = nutshell.search_by_email email.downcase
    contact_to_keep = contacts['contacts'].shift
    return if contact_to_keep.nil? or contacts['contacts'].length == 1
    contact_to_keep = nutshell.get_contact contact_to_keep['id']
    primary_email = contact_to_keep['email']['--primary']
    emails = []
    ## Merging activities
    activities = nutshell.find_activities contactId: contacts['contacts'].map{ |c| c['id'] }
    activities.each do |activity|
      activity['participants'] = [{ "id" => contact_to_keep['id'], "entityType" => "Contacts" }]
      nutshell.edit_activity(activity['id'], activity['rev'], activity)
    end
    contact_to_keep['notes'] = []
    contacts['contacts'].each_with_index do |contact, index|
      begin
        contact = nutshell.get_contact contact['id']
        ## Merging emails
        emails += contact['email'].map(&:last)
        ## Merging notes
        notes = contact['notes']
        notes.each{|n| n.delete('id') }
        notes.each{|n| n.delete('rev') }
        notes.each{|n| n.delete('originId') }
        contact_to_keep['notes'] << notes
        self.delete_contact(contact)
      rescue Exception => exception
        puts exception
      end
    end
    new_emails = { '--primary' => primary_email }
    emails.uniq.each_with_index do |email, index|
      new_emails[index + 1] = email
    end
    contact_to_keep['email'] = new_emails
    contact_to_keep.delete 'creator'
    contact_to_keep.delete 'lastContactedDate'
    contact_to_keep.delete 'contactedCount'
    contact_to_keep.delete 'owner'
    contact_to_keep.delete 'owner'
    contact_to_keep.delete 'entityType'
    contact_to_keep.delete 'htmlUrl'
    contact_to_keep.delete 'leads'
    contact_to_keep['notes'] = contact_to_keep['notes'].flatten
    contact_to_keep.delete 'notes' if contact_to_keep['notes'].empty?
    contact_to_keep.delete 'accounts'
    puts primary_email
    nutshell.edit_contact contact_to_keep['id'], contact_to_keep['rev'].to_i, contact_to_keep
  end

  def self.update_contact(structure)
    admin    = structure.main_contact
    contacts = nutshell.search_by_email admin.email.downcase
    contacts['contacts'].each_with_index do |contact, index|
      break if index > 0
      begin
        contact = nutshell.get_contact contact['id']
        new_tags = contact['tags'] || []
        new_tags.delete('Non inscrit')
        new_tags += structure.subjects.at_depth(2).map(&:name)
        new_tags += structure.subjects.at_depth(0).map(&:name)
        new_tags << 'Inscrit'
        if !structure.profile_completed?
          new_tags << 'Complet 0'
          new_tags.delete 'Complet 1'
          new_tags.delete 'Complet 2'
        elsif structure.comments_count < 5
          new_tags << 'Complet 1'
          new_tags.delete 'Complet 0'
          new_tags.delete 'Complet 2'
        elsif structure.comments_count >= 5
          new_tags << 'Complet 2'
          new_tags.delete 'Complet 0'
          new_tags.delete 'Complet 1'
        end
        address = {
          '1' => {
            'address_1'  => structure.street,
            'city'       => structure.city.name,
            'state'      => '',
            'postalCode' => structure.zip_code,
            'country'    => 'FR'
          }
        }
        new_contact = {
          'name'    => {
            'displayName' => structure.name
          },
          'description' => structure.main_contact.name,
          'tags'        => new_tags.uniq,
          'address'     => address,
          'customFields' => {
              'Profil privé' => "http://pro.coursavenue.com/etablissements/#{structure.slug}/tableau-de-bord",
              'Profil public' => "https://www.coursavenue.com/etablissements/#{structure.slug}"
          }
        }
        nutshell.edit_contact contact['id'], contact['rev'].to_i, new_contact
        puts "Updating #{admin.email.downcase} from #{structure.name}"
      rescue Exception => exception
      end
    end
    self.merge_contacts(admin.email.downcase) if contacts['contacts'].length > 1

  end

  def self.create_contact(structure)
    admin    = structure.main_contact
    contacts = nutshell.search_by_email admin.email.downcase
    # Prevent from creating multiple contacts
    return if contacts['contacts'].length > 0

    new_contact = self.create_nutshell_contact_object(structure)
    admin       = structure.main_contact
    puts "Creating #{admin.email.downcase} from #{structure.name}"
    self.nutshell.new_contact new_contact
    # Update after creating because tags fail in creation...
    self.update_contact structure
  end

  def self.delete_contact(contact)
    params = JSON.parse(nutshell.send(:build_payload, contactId: contact['id'], rev: contact['rev']))
    params['method'] = 'deleteContact'
    nutshell.send :exec_request, params.to_json
  end

  private

  # Given a structure, returns a formatted hash for nutshell API
  def self.create_nutshell_contact_object(structure)
    admin = structure.main_contact
    address = {
      '1' => {
        'address_1'  => structure.street,
        'city'       => structure.city.name,
        'state'      => '',
        'postalCode' => structure.zip_code,
        'country'    => 'FR'
      }
    }
    new_contact = {
      'address' => address,
      'tags'    => ['Inscrit']
    }
    # if it does not exists
    new_contact['name'] = structure.name
    new_contact['email'] = admin.email.downcase
    if structure.website
      new_contact['url'] = {'0' => admin.email.downcase}
    end
    if admin.phone_number.present?
      new_contact['phone'] = {'number' => admin.phone_number}
    elsif admin.mobile_phone_number.present?
      new_contact['phone'] = {'number' => admin.mobile_phone_number}
    end
    new_contact
  end
end
