class MailchimpUpdater

  def self.update(user)
    Gibbon::API.lists.subscribe({id: '34fb5a48e8',
                                 email: { email: user.email},
                                 merge_vars: {
                                   :FNAME      => user.first_name,
                                   :LNAME      => user.last_name,
                                   :GENDER     => user.gender,
                                   :CITY       => user.city.try(:name),
                                   :ZIPCODE    => user.zip_code,
                                   :REGION     => user.city.try(:region_name),
                                   :EMAILSTAT  => user.delivery_email_status
                                 },
                                   double_optin: false,
                                   update_existing: true
                                 })

  end
end
