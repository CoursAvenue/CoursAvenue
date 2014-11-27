CoursAvenue::Application.configure do

  # config.session_store :cookie_store, key: '_CoursAvenue__session', :domain => 'coursavenue.com'
  # config.session_store :cookie_store, key: '_CoursAvenue_session', :domain => 'coursavenue.com'
  CoursAvenue::Application.config.session_store :active_record_store, key: '_CoursAvenue_session_ar', domain: 'coursavenue.com'
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests

  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets  = true
  config.assets.compress = true
  # config.static_cache_control = "public, max-age=31536000"

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = false

  # See everything in the log (default is :info)
  config.log_level = :warn

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  config.cache_store = :dalli_store,
                      (ENV["MEMCACHIER_SERVERS"] || "").split(","),
                      { username:             ENV["MEMCACHIER_USERNAME"],
                        password:             ENV["MEMCACHIER_PASSWORD"],
                        failover:             true,
                        socket_timeout:       1.5,
                        socket_failure_delay: 0.2
                      }

  config.identity_cache_store = :dalli_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com"
  # config.action_controller.asset_host = "cdn%d.coursavenue.com"
  config.action_controller.asset_host = "dqggv9zcmarb3.cloudfront.net"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( email.css discovery_pass.css )
  config.assets.precompile += %w( application.pro.js modernizr.js ckeditor/config.js )

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
  config.eager_load = false
  config.active_record.migration_error = :page_load

  config.paperclip_defaults = {
    storage:      :s3,
    s3_protocol:  'https',
    s3_host_name: ENV['ENDPOINT'], # 's3-eu-west-1.amazonaws.com'
    s3_credentials: {
      bucket:            ENV['AWS_BUCKET'],
      access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    },
    url: ':s3_alias_url',
    s3_host_alias: ENV['PAPERCLIP_S3_HOST_ALIAS'],
    path: ":class/:attachment/:id_partition/:style/:filename"
  }

  # ------------ Mailer configuration
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'coursavenue.com' }
  config.action_mailer.asset_host          = 'https://www.coursavenue.com'

  config.action_mailer.smtp_settings = {
    address:          'smtp.mandrillapp.com',
    port:             '587',
    user_name:        ENV["MANDRILL_USERNAME"],
    password:         ENV["MANDRILL_PASSWORD"],
    domain:           'coursavenue.com',
    authentication:   :plain
  }

  PayPal::Recurring.configure do |config|
    config.username  = ENV['PAYPAL_LOGIN']
    config.password  = ENV['PAYPAL_PASSWORD']
    config.signature = ENV['PAYPAL_SIGNATURE']
  end

  config.middleware.use Rack::Prerender, prerender_service_url: ENV['PRERENDER_SERVICE_URL']
end
