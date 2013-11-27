class UpdateUserProfileFromExistingUsers < ActiveRecord::Migration
  def change
    bar = ProgressBar.new UserProfile.count
    UserProfile.find_each do |user_profile|
      bar.increment!
      if user_profile.user.nil?
        user_profile.destroy
      else
        user_profile.email      = user_profile.user.email
        user_profile.first_name = user_profile.user.name
        user_profile.save!
      end
    end
  end
end
