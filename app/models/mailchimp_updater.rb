class MailchimpUpdater

  def self.list_id
    return {
      user:               '34fb5a48e8',
      structure:          '79f30bcce9',
      sleeping_structure: '8318169fe4'
    }
  end

  def self.update_user(user)
    Gibbon::API.lists.subscribe({id: MailchimpUpdater.list_id[:user],
                                 email: { email: user.email},
                                 merge_vars: {
                                   :FNAME      => user.first_name.try(:capitalize),
                                   :LNAME      => user.last_name,
                                   :GENDER     => user.gender,
                                   :CITY       => user.city.try(:name),
                                   :ZIPCODE    => user.zip_code,
                                   :REGION     => user.city.try(:region_name),
                                   :EMAILSTAT  => user.delivery_email_status,
                                   :ID         => user.id,
                                   :GROUP      => user.id.modulo(6),
                                   :SLEEPING   => (user.active? ? 'Oui' : 'Non')
                                 },
                                   double_optin: false,
                                   update_existing: true
                                 })

  end

  def self.update_structure(structure)
    Gibbon::API.lists.subscribe({id: MailchimpUpdater.list_id[:structure],
                                 email: { email: structure.main_contact.email},
                                 merge_vars: {
                                   :NAME      => structure.name,
                                   :PARISIAN  => (structure.parisian? ? 'Oui' : 'Non'),
                                   :SLEEPING  => (structure.is_sleeping? ? 'Oui' : 'Non'),
                                   :SLUG      => structure.slug
                                 },
                                   double_optin: false,
                                   update_existing: true
                                 })

  end

  def self.update_sleeping_structures(structure)
    Gibbon::API.lists.subscribe({id: list_id[:sleeping_structure],
                                 email: { email: structure.main_contact.email},
                                 merge_vars: {
                                   :ACTIVE      => 'Yes'
                                 },
                                   double_optin: false,
                                   update_existing: true
                                 })

  end
end
