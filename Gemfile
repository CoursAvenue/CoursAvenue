# encoding: utf-8
source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '4.0.4'

gem 'rack-attack', '~>3.0.0'
gem 'rack-timeout', '~> 0.0.4'

gem 'filepicker-rails'

gem 'activerecord-session_store', github: 'rails/activerecord-session_store'

# Webserver
# gem 'unicorn'
# gem 'puma'
gem 'passenger'

# Database
gem 'pg'

# Lets you access the version of the deploy on Heroku
# Mainly used for caching: see:  config/bust_http_cache.rb
gem 'heroku-api'
gem 'bust_rails_etags'          # https://github.com/n8/bust_rails_etags
gem 'bugsnag'

# For pagination
gem 'kaminari', '~> 0.15.1'

# Monitoring
gem 'newrelic_rpm'          , '~>3.6.8.164'

# Used to update contacts in nutshell CRM
gem 'nutshell-crm'

# Used for the blog. Lets us have coursavenue.com/blog
gem 'rack-reverse-proxy',  require: 'rack/reverse_proxy'
gem 'rack-cors',           require: 'rack/cors'

# Formats numbers and prices regarding the locale
# TODO Fix this gem
# The gem is not ready yet for Rails 4.
# gem 'delocalize', '~>0.3.2'

# Caching
gem 'memcachier'
gem 'dalli'      , '~>2.6.4'

# Non stored hash models
# See Level and Audience model
gem 'active_hash'               , '~>1.2.0'
gem 'rails-observers'           , '~>0.1.2'

# Transform urls into images, videos etc. Used in medias.
gem 'auto_html'                 , '~>1.6.2'

# Must be before jobs
gem 'protected_attributes'      , '~>1.0.3'

# Queue of jobs
gem 'delayed_job'               , '~>4.0.0'#, git: 'git://github.com/nim1989/delayed_job.git'
gem 'delayed_job_active_record' , '~>4.0.0'
gem 'daemons'                   , '~>1.1.9'
# Needed for hirefire to handle to access to jobs count
gem 'hirefire-resource'

# Show progress bars in scripts
gem 'progress_bar'              , '~>1.0.0'

# For image handling
gem 'paperclip'                 , '~>3.5.1'

# For handy SQL queries
gem 'squeel'                    , '~>1.1.1'
# For having models acting like trees
gem 'ancestry'                  , '~>2.0.0'

# Nice helper to use google maps
gem 'gmaps4rails'               , '~>2.1.1'
# Helper methods for geolocations
gem 'geocoder'                  , '~>1.1.9'
# To have model serializers apart from models
gem 'active_model_serializers'  , '~>0.8.1'

# Generate slugs for records
gem 'friendly_id'               , '~>5.0.0'
# Handy forms
gem 'simple_form'               , '~>3.0.0'
# Dry the controllers
gem 'inherited_resources'       , '~>1.4.1'

# For messaging
gem 'mailboxer'                 , '~> 0.12.0.rc1', git: 'git://github.com/mailboxer/mailboxer.git'

# For authorizations
gem 'cancancan'                 , '~>1.7.0'
# gem 'cancan'                    , '~>1.6.10'
# For authentication
gem 'devise'                    , '~>3.2.3'
# Facebook connect
gem 'omniauth-facebook'         , '~>1.4.1'
# A full-stack Facebook Graph API wrapper in Ruby.
gem 'fb_graph'                  , '~>2.7.10'
# Helps access to gmail contacts etc.
gem 'omnicontacts'              , '~>0.3.4'
gem 'certified'                 , '~>0.1.1'

# Search engine
gem 'sunspot'                   , '~>2.0.0'
# Add solr server for development
gem 'sunspot_solr'              , '~>2.0.0', group: :development
gem 'sunspot_rails'             , '~>2.0.0'
gem 'sunspot-rails-tester'      , '~>1.0.0'

gem 'truncate_html'             , '~>0.9.2'

# Add taggable behavior to models
# https://github.com/mbleigh/acts-as-taggable-on
gem 'acts-as-taggable-on'       , '~>3.0.1'

# Prevent from real deletion
# acts_as_paranoid
gem 'paranoia'                  , '~>2.0'

# Helps having a clean ruby sitemap
gem 'sitemap_generator'         , '~>4.2.0'
# Mailchimp API
gem 'gibbon'                    , '~>1.0.4'

# Transform external CSS stylesheets into inline CSS for emails
gem 'roadie'                    , '~>2.4.3'

gem 'fingerprintjs-rails'       , '~>0.5.3'

# Includes Backbone
gem 'railsy_backbone'           , '~>0.0.5'
# Includes Backbone Marionette
gem 'marionette-rails'          , '~>1.4.1'
# Includes bacbone.relational
gem 'backbone-relational-rails' , '~>0.8.7'
# See issue: https://github.com/leshill/handlebars_assets/pull/46
gem 'handlebars_assets'         , '~>0.15', git: 'git://github.com/variousauthors/handlebars_assets.git'
# Decorator
gem 'draper'                    , '~>1.3.0'
# allows sharing of handlebars templates
gem 'sht_rails'
gem 'sass-rails'                , '~>4.0.1'
gem 'haml'                      , '~>4.0.3'
gem 'uglifier'                  , '>= 1.0.3'
gem 'coffee-rails'              , '~>4.0.0'
gem 'js-routes'                 , '~>0.9.7'

# Load FontAwesome
gem 'font-awesome-rails'        , '~>4.0.3.1'
# Load jQuery
gem 'jquery-rails'              , '~>3.0.4'
# Load Compass utilities
gem 'compass'                   , '~>0.12.2'
gem 'compass-rails'             , '~>2.0.0.pre', git: 'git://github.com/Compass/compass-rails.git', branch: '2-0-stable'
# Load Inuit CSS
gem 'compass-inuit'             , '~>5.0.2'
# Enable haml

gem 'turbolinks'
gem 'jquery-turbolinks'

# For uploading to amazon CDN
gem 'aws-sdk'                   , '~>1.36.1'

# Roo implements read access for all spreadsheet, xls and more
gem 'roo'                   , '~>1.13.2'

# Rack::UTF8Sanitizer is a Rack middleware which cleans up invalid UTF8 characters in request URI and headers.
# https://github.com/whitequark/rack-utf8_sanitizer
gem 'rack-utf8_sanitizer'

group :production, :staging do
  gem 'execjs'
  gem 'rails_12factor'
  # Sync assets to S3 and CloudFront
  gem 'asset_sync'                , '~>1.0.0'
end

group :test do
  gem 'factory_girl_rails', '~>4.3.0'
  gem 'rspec-rails'       , '~>2.14.1'
  gem 'rspec-instafail'   , '~>0.2.4'
  gem 'faker'             , '~>1.2.0'
  gem 'simplecov'         , '~>0.7.1'
  # gem 'sunspot_test'
  gem 'database_cleaner'  , '~>1.2.0'
  gem 'capybara'          , '~>2.2.1'
  gem 'selenium-webdriver', '~>2.40.0'
end

group :development do
  # Removes useless logging in dev.
  gem 'brakeman'          , '~>2.3.1'
  gem 'rubocop'           , '~>0.18.1'

  # Removes useless logging in dev.
  gem 'quiet_assets', '~>1.0.2'

  # Show errors nicely
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'awesome_print'
  gem 'meta_request', '0.2.6'
end

group :development, :test do
  gem 'debugger' # this is causing problems for Andre
  # Permits to travel in the past
  gem 'delorean'
  gem 'dotenv-rails'
end

gem 'rmagick', '~>2.13.2', require: 'RMagick'

# Rails 4 upgrade
gem 'actionpack-action_caching', '~>1.0.0'
