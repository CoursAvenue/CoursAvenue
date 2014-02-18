class CreateUserForInfoContacts < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      next if structure.main_contact.nil? or structure.main_contact.mailbox.conversations.empty?
      demande_dinfo_emails = []
      structure.main_contact.mailbox.conversations.where{subject == "Demande d'informations"}.each do |conversations|
        recipient = conversations.recipients.select{|recipient| recipient.is_a? User }.first
        next if recipient.nil?
        user_profile = structure.user_profiles.where(email: recipient.email).first_or_create

        user_profile.first_name = recipient.first_name
        user_profile.last_name  = recipient.last_name

        structure.tag(user_profile, with: UserProfile::DEFAULT_TAGS[:contacts], on: :tags)
      end
    end
  end

  def down
  end
end
