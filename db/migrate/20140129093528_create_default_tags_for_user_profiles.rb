class CreateDefaultTagsForUserProfiles < ActiveRecord::Migration

  def up
    bar = ProgressBar.new Structure.count
    Structure.find_in_batches batch_size: 50 do |structure_group|
      structure_group.each do |structure|
        bar.increment!
        next unless structure.main_contact
        structure.user_profiles.find_in_batches batch_size: 250 do |user_profile_group|
          user_profile_group.each do |user_profile|
            user_profile_email        = user_profile.email
            user_profile_name         = user_profile.first_name
            if user_profile_name.present?
              user_profile.first_name = user_profile_name.split(' ')[0..user_profile_name.split(' ').length - 2].join(' ') # All except the last
              user_profile.last_name  = user_profile_name.split(' ').last                                                  if user_profile.last_name.blank? and self.user_profile_name.split(' ').length > 1
              user_profile.save
            end
            if structure.comments.where{email == user_profile_email}.any?
              structure.tag(user_profile, with: UserProfile::DEFAULT_TAGS[:comments], on: :tags)
            end
          end
          GC.start
        end
      end
      GC.start
    end
  end

  def down
  end
end
