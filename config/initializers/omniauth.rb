OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :facebook, '589759807705512', '2e0ced1408e8f72e3b0a555e1bc03471', provider_ignores_state: true
  #          :scope => 'email,user_location,age,user_birthday,gender', :display => 'popup'
end

