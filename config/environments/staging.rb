CoursAvenue::Application.configure do
  # config.session_store :cookie_store, key: '_CoursAvenue_session', :domain => 'coursavenue.com'
  # Settings specified here will take precedence over those in config/application.rb

  CoursAvenue::Application.config.session_store :active_record_store, key: '_CoursAvenue_session_ar', domain: 'coursavenue.com'
  # Code is not reloaded between requests

  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets  = true
  # config.static_cache_control = "public, max-age=31536000"

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :info

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  config.cache_store = :dalli_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = "https://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( email.css)
  config.assets.precompile += %w( application.pro.js modernizr.js )
  config.assets.precompile += Ckeditor.assets

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_protocol => 'http',
    :s3_host_name => 's3-eu-west-1.amazonaws.com',
    :s3_credentials => {
      :bucket => ENV['AWS_BUCKET'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }

  # ------------ Mailer configuration
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'coursavenue.com' }
  config.action_mailer.asset_host = 'http://staging.coursavenue.com'

  config.action_mailer.smtp_settings = {
    address:          "in.mailjet.com",
    port:             '587',
    user_name:        ENV["MAILJET_USERNAME"],
    password:         ENV["MAILJET_PASSWORD"],
    domain:           'coursavenue.com',
    authentication:   :plain
  }

  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)

  config.eager_load = false
end
