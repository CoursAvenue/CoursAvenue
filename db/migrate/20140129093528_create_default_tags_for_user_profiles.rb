class CreateDefaultTagsForUserProfiles < ActiveRecord::Migration

  def up
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      next unless structure.main_contact
      demande_dinfo_emails = []
      structure.main_contact.mailbox.conversations.where{subject == "Demande d'informations"}.each do |conversations|
        demande_dinfo_emails << conversations.recipients.map(&:email)
      end

      demande_dinfo_emails = demande_dinfo_emails.flatten

      structure.user_profiles.find_each do |user_profile|
        user_profile_email      = user_profile.email
        user_profile_name       = user_profile.first_name
        if user_profile_name.present?
          user_profile.first_name = user_profile_name.split(' ')[0..-2].join(' ')
          user_profile.last_name  = user_profile_name.split(' ').last if user_profile_name.split(' ').length > 1
          user_profile.save
        end
        tags = []
        tags << UserProfile::DEFAULT_TAGS[:comments] if structure.comments.where{email == user_profile_email}
        if demande_dinfo_emails.include? user_profile_email
          tags << UserProfile::DEFAULT_TAGS[:contacts]
          puts user_profile_email
          puts structure.slug
        end
        structure.tag(user_profile, with: tags.join(','), on: :tags) if tags.present?
      end
    end
  end

  def down
  end
end
