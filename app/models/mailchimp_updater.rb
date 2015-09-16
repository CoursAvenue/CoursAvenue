class MailchimpUpdater

  def self.list_id
    return {
      user:               '34fb5a48e8',
      structure:          '79f30bcce9',
      sleeping_structure: 'f896ec23c0'
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
                                   :SLEEPING   => (user.active? ? 'Oui' : 'Non'),
                                   :DISCIPLINE => MailchimpUpdater.get_subject_name(user.dominant_subject)
                                 },
                                   double_optin: false,
                                   update_existing: true
                                 })

  end

  def self.update_structure(structure)
    Gibbon::API.lists.subscribe({id: MailchimpUpdater.list_id[:structure],
                                 email: { email: structure.admin.email},
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
    return if structure.admin.nil?
    gibbon = Gibbon::API.new(ENV['MAILCHIMP_API_KEY_2'])
    gibbon.lists.subscribe({id: list_id[:sleeping_structure],
                                 email: { email: structure.admin.email},
                                 merge_vars: {
                                   :ACTIVE      => 'Yes'
                                 },
                                   double_optin: false,
                                   update_existing: true
                                 })

  end
  def self.get_subject_name(subject)
    return '' if subject.nil?
    {
      'danse'                           => 'Danse',
      'theatre-scene'                   => 'Théâtre',
      'yoga-bien-etre-sante'            => 'Yoga et bien-être',
      'musique-chant'                   => 'Musique',
      'dessin-peinture-arts-plastiques' => 'Dessin',
      'sports-arts-martiaux'            => 'Sports',
      'cuisine-vins'                    => 'Cuisine',
      'photo-video'                     => 'Photo et vidéo',
      'deco-mode-bricolage'             => 'Déco'
    }[subject.slug]
  end
end
