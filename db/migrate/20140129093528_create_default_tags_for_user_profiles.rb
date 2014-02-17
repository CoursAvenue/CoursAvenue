class CreateDefaultTagsForUserProfiles < ActiveRecord::Migration

  def up
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      next unless structure.main_contact
      GC.start
      structure.user_profiles.find_each do |user_profile|
        user_profile_email        = user_profile.email
        user_profile_name         = user_profile.first_name
        if user_profile_name.present?
          user_profile.first_name = user_profile_name.split(' ')[0..-2].join(' ')
          user_profile.last_name  = user_profile_name.split(' ').last if user_profile_name.split(' ').length > 1
          user_profile.save
        end
        if structure.comments.where{email == user_profile_email}
          structure.tag(user_profile, with: UserProfile::DEFAULT_TAGS[:comments], on: :tags)
        end
      end
    end
  end

  def down
  end
end
