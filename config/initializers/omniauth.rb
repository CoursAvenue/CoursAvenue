OmniAuth.config.logger = Rails.logger

# Already in devise.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], provider_ignores_state: true, scope: 'public_profile,email,user_location,user_birthday,user_activities,user_friends,manage_pages', display: 'popup'
end
