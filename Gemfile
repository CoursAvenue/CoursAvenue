# encoding: utf-8
source 'https://rubygems.org'

ruby '2.2.2'

gem 'rails', '4.1.8'

gem 'rack-attack',  '~> 4.2.0'
gem 'rack-timeout', '~> 0.2.1'
# Will redirect 301 if not on coursavenue.com host
gem 'rack-canonical-host', '~> 0.1.0'

gem 'filepicker-rails', '~> 1.3.0'

gem 'activerecord-session_store', github: 'rails/activerecord-session_store'

gem 'rack-ssl-enforcer'   , '~> 0.2.8'
gem 'lograge'             , '~> 0.3.1'

gem 'intercom'            , '~> 3.0.2'
gem 'intercom-rails'      , '~> 0.2.28'
gem 'closeio'             , '~> 2.0.6'

# Webserver
# gem 'unicorn'
# gem 'puma'
gem 'passenger',          '~> 5.0.4'
gem 'algoliasearch-rails', '~> 1.14.1'
gem 'google-api-client'  , '~> 0.8.2'

# Database
gem 'pg',               '~> 0.18.1'
gem 'bitly',            '~> 0.10.4'

gem 'actionpack-page_caching', '~> 1.0.2'
# Lets you access the version of the deploy on Heroku
# Mainly used for caching: see:  config/bust_http_cache.rb
gem 'heroku-api'      , '~> 0.3.22'
gem 'bust_rails_etags', '~> 0.0.5'  # https://github.com/n8/bust_rails_etags
gem 'bugsnag'         , '~> 2.8.1'

gem 'paypal-recurring', '~> 1.1.0'

# For pagination
gem 'kaminari', '~> 0.16.3'

# Monitoring
gem 'newrelic_rpm'          , '~> 3.10.0.279'

gem 'highrise'

# Used for the blog. Lets us have coursavenue.com/blog
gem 'rack-reverse-proxy', '~> 0.4.4',  require: 'rack/reverse_proxy'
gem 'rack-cors'         , '~> 0.3.1',  require: 'rack/cors'

# Formats numbers and prices regarding the locale
# https://github.com/carlosantoniodasilva/i18n_alchemy
gem 'i18n_alchemy'      , '~> 0.2.1'

# Caching
gem 'memcachier'                , '~> 0.0.2'
gem 'dalli'                     , '~> 2.7.2'

# Non stored hash models
# See Level and Audience model
gem 'active_hash'               , '~> 1.4.0'

# Transform urls into images, videos etc. Used in medias.
gem 'auto_html'                 , '~> 1.6.4'

# Must be before jobs
gem 'protected_attributes'      , '~> 1.0.8'

# Queue of jobs
gem 'delayed_job'               , '~> 4.0.6'#, git: 'git://github.com/nim1989/delayed_job.git'
gem 'delayed_job_active_record' , '~> 4.0.3'
gem 'daemons'                   , '~> 1.2.1'
# Needed for hirefire to handle to access to jobs count
gem 'hirefire-resource'         , '~> 0.3.5'

gem 'carrierwave'               , '~> 0.10.0'
gem 'cloudinary'                , '~> 1.1.0'

# Show progress bars in scripts
gem 'progress_bar'              , '~> 1.0.3'

# For handy SQL queries
# gem 'squeel'                    , '~> 1.1.1'

# For having models acting like trees
gem 'ancestry'                  , '~> 2.1.0'

# Helper methods for geolocations
gem 'geocoder'                  , '~> 1.2.9'
# To have model serializers apart from models
gem 'active_model_serializers'  , '0.8.3'

# Generate slugs for records
gem 'friendly_id'               , '~>5.1.0'
# Handy forms
gem 'simple_form'               , '~> 3.1.0'
# Dry the controllers
gem 'inherited_resources'       , '~> 1.6.0'

# For messaging
gem 'mailboxer'                 , '~> 0.12.5'

# For authorizations
gem 'cancancan'                 , '~> 1.12.0'
# gem 'cancan'                    , '~> 1.6.10'
# For authentication
gem 'devise'                    , '~> 3.5.1'
# For facebook connect or more
gem 'omniauth-facebook'         , '~> 2.0.1'
gem 'omniauth'                  , '~> 1.2.2'
# A full-stack Facebook Graph API wrapper in Ruby.
gem 'fb_graph'                  , '~> 2.7.17'
gem 'certified'                 , '~> 1.0.0'

# Search engine
gem 'sunspot'                   , '~> 2.2.0'
gem 'sunspot_rails'             , '~> 2.2.0'

gem 'truncate_html'             , '~> 0.9.3'

# Add taggable behavior to models
# https://github.com/mbleigh/acts-as-taggable-on
gem 'acts-as-taggable-on'       , '~> 3.5.0'

# Prevent from real deletion
# acts_as_paranoid
gem 'paranoia'                  , '~> 2.1.0'

# Helps having a clean ruby sitemap
gem 'sitemap_generator'         , '~> 5.0.5'
# Mailchimp API
gem 'gibbon'                    , '~> 1.1.5'

# Transform external CSS stylesheets into inline CSS for emails
gem 'roadie'                    , '~> 3.0.5'
gem 'roadie-rails'              , '~> 1.0.6'

gem 'browserify-rails'          , '~> 1.0.1'
gem 'react-rails'               , '~> 1.0.0'
gem 'handlebars_assets'         , '~> 0.20.1'
# Decorator
gem 'draper'                    , '~> 1.4.0'
# allows sharing of handlebars templates
gem 'sht_rails'                 , '~> 0.2.2'
gem 'sass-rails'                , '~> 5.0.1'
gem 'autoprefixer-rails'        , '~> 5.2.1.3'
gem 'coffee-rails'              , '~> 4.1.0'
gem 'haml'                      , '~> 4.0.6'
gem 'uglifier'                  , '>= 2.7.1'
gem 'js-routes'                 , '~> 1.0.0'

gem 'activesupport-json_encoder', '~> 1.1.0'

# Load FontAwesome
gem 'font-awesome-rails'        , '~> 4.3.0.0'
# Load jQuery
gem 'jquery-rails'              , '~> 3.1.2 '
# Load Inuit CSS
gem 'compass'                   , '~>1.0.3'
gem 'compass-rails'             , '~> 2.0.4'
gem 'compass-inuit'             , '~>5.0.2'
# Enable haml

# gem 'turbolinks'
# gem 'jquery-turbolinks'

# For uploading to amazon CDN
gem 'aws-sdk'                   , '~> 1.36.1' #'~> 2.0.30'

# Roo implements read access for all spreadsheet, xls and more
gem 'roo'                       , '~> 1.13.2'

# XLSX spreadsheet generation
gem 'axlsx'                     , '~> 2.0.1'

# Rack::UTF8Sanitizer is a Rack middleware which cleans up invalid UTF8 characters in request URI and headers.
# https://github.com/whitequark/rack-utf8_sanitizer
gem 'rack-utf8_sanitizer'       , '~> 1.3.0'

# Run `image_optim -r app/assets/images` to compress all assets locally
gem 'image_optim'               , '~> 0.20.2'
gem 'image_optim_pack'          , '~> 0.2.1.20150310'

gem 'execjs'                    , '~> 2.5.2'

group :production, :staging do
  gem 'rails_12factor'            , '~> 0.0.3'
  # Sync assets to S3 and CloudFront
  gem 'asset_sync'                , '~> 1.1.0'
  # Enable gzip compression on heroku, but don't compress images
  # gem 'heroku_rails_deflate'      , '~> 1.0.3'
  # gem 'rack-zippy'
  gem 'heroku-deflater'           , '~> 0.5.3'
  # gem 'sprockets-image_compressor', '~> 0.3.0'
  gem 'htmlcompressor'            , '~> 0.1.2'
end

group :test do
  gem 'sunspot-rails-tester', '~> 1.0.0'
  gem 'simplecov',            '~> 0.9.1'
  gem 'database_cleaner',     '~> 1.2.0'
  gem 'capybara',             '~> 2.2.1'
  gem 'rspec-instafail',      '~> 0.2.6', require: false
  gem 'shoulda-matchers',     '~> 2.8.0', require: false
end

group :development do

  # Add solr server for development
  gem 'sunspot_solr'              , '~> 2.2.0'
  gem 'rails_best_practices', require: false
  gem 'ruby-prof'
  # Speed up slow Rails development mode
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git'
  # Guard::Pow automatically manage Pow applications restart
  gem 'guard-pow', require: false
  # Removes useless logging in dev.
  gem 'fontcustom'              , '~> 1.3.8', github: 'nim1989/fontcustom'
  gem 'brakeman'                , '~> 2.3.1'
  gem 'rubocop'                 , '~> 0.18.1', require: false

  # Removes useless logging in dev.
  gem 'quiet_assets', '~> 1.0.3'

  # Show errors nicely
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'awesome_print'
  gem 'meta_request', '~> 0.3.0'
  gem 'pry-rails'
end

group :development, :test do
  # Debugger
  gem 'byebug'
  # Permits to travel in the past
  gem 'delorean'
  gem 'faker',                 '~> 1.4.3'
  gem 'factory_girl_rails',    '~> 4.5.0'
  gem 'rspec',                 '~> 3.2.0'
  gem 'rspec-core',            '~> 3.2.0'
  gem 'rspec-support',         '~> 3.2.0'
  gem 'rspec-rails',           '~> 3.2.1'
  # gem 'stripe-ruby-mock',      '~> 2.1.0', :require => 'stripe_mock'
  gem 'stripe-ruby-mock', github: 'wanelo/stripe-ruby-mock', ref: '5ec5dda994975a95653ce9f0a15f7f3316a185d8', require: 'stripe_mock'
end

gem 'dotenv-rails', '~> 2.0.0'

gem 'rmagick', '~> 2.15.4', require: 'RMagick'

# Rails 4 upgrade
gem 'actionpack-action_caching', '~> 1.1.1'

# ActiveRecord Caching
gem 'identity_cache'           , '~> 0.2.3'
gem 'cityhash'                 , '~> 0.8.1'

# JS heavy pages pre-rendering
gem 'prerender_rails'          , '~> 1.1.2'

# Track envents starting in the App
gem 'mixpanel-ruby'            , '~> 2.0.1'

# Email reception
gem 'griddler'         , '~> 1.1.0'
gem 'griddler-mandrill', '~> 1.0.2'

# Send (and receive) SMS
gem 'nexmo', '~> 2.0.0'

group :development do
  # Must be loaded after mongo
  gem 'bullet'                , '~> 4.14.0'
end

# PDF generation for orders
gem 'wicked_pdf'        , '~> 0.11.0'
gem 'wkhtmltopdf-binary', '~> 0.9.9.3', require: false

# Contact importing
gem 'omnicontacts', '~> 0.3.5'

# Email sending for teachers
gem 'mandrill-api'

# Google Analytics integration.
gem 'legato', '~> 0.4.0'

# Payments
gem 'stripe', '~> 1.20.1'

# Form object.
gem 'virtus', '~> 1.0.5'

# Full text search.
gem 'textacular', '~> 3.0'

# Validation of YouTube videos.
gem 'ruby-oembed', '~> 0.8.14', require: false
