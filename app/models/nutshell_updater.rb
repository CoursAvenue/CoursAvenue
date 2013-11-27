# encoding: utf-8
class NutshellUpdater

  @@nutshell = nil

  def self.nutshell
    if @@nutshell.nil?
      @@nutshell = NutshellCrm::Client.new "nima@coursavenue.com", "e9dd959a489948e664101c1e9f77fd5463032665"
    else
      @@nutshell
    end
  end

  def self.update(structure)
    if (admin = structure.main_contact)
      contacts = self.nutshell.search_by_email admin.email
      if contacts['contacts'].any?
        puts 'Updating contact'
        self.update_contact(structure)
      else
        puts 'Creating contact'
        self.create_contact(structure)
      end
    end
  end

  def self.update_contact(structure)
    admin    = structure.main_contact
    contacts = nutshell.search_by_email admin.email
    contacts['contacts'].each do |contact|
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
          'tags'    => new_tags.uniq,
          'address' => address,
          'customFields' => {
              'Profil privé' => "http://pro.coursavenue.com/etablissements/#{structure.slug}/tableau-de-bord",
              'Profil public' => "http://www.coursavenue.com/etablissements/#{structure.slug}"
          }
        }
        nutshell.edit_contact contact['id'], contact['rev'].to_i, new_contact
        puts "Updating #{admin.email} from #{structure.name}"
      rescue Exception => exception
        puts exception
      end
    end

  end

  def self.create_contact(structure)
    new_contact = self.create_nutshell_contact_object(structure)
    admin       = structure.main_contact
    puts "Creating #{admin.email} from #{structure.name}"
    self.nutshell.new_contact new_contact
    # Update after creating because tags fail in creation...
    self.update_contact structure
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
    new_contact['email'] = admin.email
    if structure.website
      new_contact['url'] = {'0' => admin.email}
    end
    if admin.phone_number.present?
      new_contact['phone'] = {'number' => admin.phone_number}
    elsif admin.mobile_phone_number.present?
      new_contact['phone'] = {'number' => admin.mobile_phone_number}
    end
    new_contact
  end
end
