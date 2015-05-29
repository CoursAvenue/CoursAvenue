CoursAvenue::Application.configure do
  # config.session_store :cookie_store, key: '_CoursAvenue_session', :domain => 'coursavenue.dev'
  CoursAvenue::Application.config.session_store :active_record_store, key: '_CoursAvenue_session_ar', domain: 'coursavenue.dev'
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  # This is added for IdentityCache.
  config.action_controller.perform_caching = false

  # config.cache_store = :dalli_store
  # config.identity_cache_store = :dalli_store

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  # ------------ Mailer configuration
  config.action_mailer.default_url_options = { :host => 'coursavenue.dev' }
  config.action_mailer.asset_host = 'http://coursavenue.dev'

  config.action_mailer.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => 'gmail.com',
    :user_name => ENV.fetch('SMTP_USERNAME') { 'v2r.test@gmail.com' },
    :password => ENV.fetch('SMTP_PASSWORD') { 'xnnc8cesJO' },
    :authentication => 'plain',
    :enable_starttls_auto => true
  }
  # config.action_mailer.smtp_settings = {
  #   address:          'smtp.mandrillapp.com',
  #   port:             '587',
  #   user_name:        ENV["MANDRILL_USERNAME"],
  #   password:         ENV["MANDRILL_PASSWORD"],
  #   domain:           'coursavenue.com',
  #   authentication:   :plain
  # }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # config.log_level = :info

  # Expands the lines which load the assets
  config.assets.debug = true

  # prevent loading files from /public/assets
  config.serve_static_assets = false

  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)

  # auto rotate log files, keep 2 of 5MB each
  # config.logger = Logger.new(config.paths.log.first, 1, 5.megabytes)

  # ACTIVATE THE FOLLOWING ONLY FOR READING PURPOSE
  # config.paperclip_defaults = {
  #   :storage => :s3,
  #   :s3_protocol => 'https',
  #   # 's3-eu-west-1.amazonaws.com'
  #   :s3_host_name => ENV['ENDPOINT'],
  #   :s3_credentials => {
  #     :bucket => 'coursavenue',
  #     :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  #     :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  #   }
  # }

  PayPal::Recurring.configure do |config|
    config.sandbox   = true
    config.username  = ENV['PAYPAL_TEST_LOGIN']
    config.password  = ENV['PAYPAL_TEST_PASSWORD']
    config.signature = ENV['PAYPAL_TEST_SIGNATURE']
  end

  # Add prerender middlewer only if the sevice URL is defined and reachable

  # if ENV['PRERENDER_SERVICE_URL'].present?
  #   config.middleware.use Rack::Prerender, prerender_service_url: ENV['PRERENDER_SERVICE_URL']
  # end
end
