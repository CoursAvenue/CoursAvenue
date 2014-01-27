class MailchimpUpdater

  def self.update(structure)
    admin = structure.main_contact
    return if admin.nil?
    Gibbon::API.lists.subscribe({id: '0f824f0bd2',
                                 email: { email: admin.email},
                                 merge_vars: {
                                   :NAME       => structure.name,
                                   :SUBJ1      => structure.subjects.at_depth(0).map(&:name),
                                   :SUBJ3      => structure.subjects.at_depth(2).map(&:name),
                                   :ZIPCODE    => structure.zip_code,
                                   :RECO_COUNT => structure.comments_count,
                                   :NWS_OPT_IN => (admin.newsletter_email_opt_in? ? 'Oui' : 'Non'),
                                   :MND_OPT_IN => (admin.monday_email_opt_in? ? 'Oui' : 'Non'),
                                 },
                                   double_optin: false,
                                   update_existing: true
                                 })

  end

end

