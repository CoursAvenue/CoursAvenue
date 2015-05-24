# encoding: UTF-8
require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module CoursAvenue
  class Application < Rails::Application

    MANDRILL_REPLY_TO_DOMAIN = Rails.env.staging? ? 'reply-staging.coursaven.eu' : 'reply.coursavenue.com'
    AMAZON_S3                = AWS::S3.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
    S3_BUCKET                = AMAZON_S3.buckets[ENV['AWS_BUCKET']]
    FACEBOOK_APP_ID          = 589759807705512

    config.action_controller.page_cache_directory = "#{Rails.root.to_s}/public/deploy"
    config.action_dispatch.default_headers = {
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Request-Method' => '*'
    }
    config.middleware.insert_before ActionDispatch::Static, Rack::SslEnforcer, ignore: /.*widget_ext.*/ if Rails.env.production?

    # S3 = AWS::S3.new(
    #   :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    #   :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    # )
    # S3_BUCKET = S3.buckets[ENV['AWS_BUCKET']]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.i18n.default_locale = :fr
    config.i18n.locale = :fr

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.image_optim = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Will not load the environment when compile the assets
    # See: http://www.simonecarletti.com/blog/2012/02/heroku-and-rails-3-2-assetprecompile-error/

    config.generators do |g|
      g.test_framework      :rspec, :fixtures => true, :views => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    config.to_prepare do
      Devise::Mailer.layout 'email'
    end

    config.generators do |g|
      g.orm :active_record
    end

    # Filepicker
    config.filepicker_rails.api_key = ENV['FILEPICKER_API_KEY']

    config.middleware.insert_before "Rack::Runtime", Rack::UTF8Sanitizer

    ROADIE_I_KNOW_ABOUT_VERSION_3 = true # Remove after Roadie 3.1
    config.roadie.url_options = { host: 'coursavenue.com' }

    config.browserify_rails.commandline_options = "-t reactify --extension=\".js.jsx\""
  end
end
