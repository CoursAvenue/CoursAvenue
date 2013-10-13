CoursAvenue::Application.configure do
  # config.session_store :cookie_store, key: '_CoursAvenue_session', :domain => 'coursavenue.dev'

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  # ------------ Mailer configuration
  config.action_mailer.default_url_options = { :host => 'coursavenue.dev' }
  config.action_mailer.asset_host = 'http://coursavenue.dev'

  config.action_mailer.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => 'gmail.com',
    :user_name => 'v2r.test@gmail.com',
    :password => 'xnnc8cesJO',
    :authentication => 'plain',
    :enable_starttls_auto => true
  }
  # config.action_mailer.smtp_settings = {
  #   :address => "smtp.mandrillapp.com",
  #   :port => 587,
  #   :user_name => 'app9696879@heroku.com',
  #   :password  => 'Qf5ITuqN9LXZez-tUC_JWg'
  # }
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = true

  # prevent loading files from /public/assets
  config.serve_static_assets = false

  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)

  # auto rotate log files, keep 2 of 5MB each
  # config.logger = Logger.new(config.paths.log.first, 1, 5.megabytes)
end
