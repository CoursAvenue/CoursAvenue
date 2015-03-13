# encoding: utf-8
source 'https://rubygems.org'

ruby '2.2.1'

gem 'rails', '4.1.8'

gem 'rack-attack',  '~>3.0.0'
gem 'rack-timeout', '~> 0.0.4'
# Will redirect 301 if not on coursavenue.com host
gem 'rack-canonical-host', '~> 0.1.0'

gem 'filepicker-rails', '~>1.3.0'

gem 'activerecord-session_store', github: 'rails/activerecord-session_store'

gem 'rack-ssl-enforcer',    '~> 0.2.7'
gem 'lograge'

gem 'intercom-rails'
# gem 'closeio'              , '~>2.0.4'
gem 'closeio', github: 'nim1989/closeio'

# Webserver
# gem 'unicorn'
# gem 'puma'
gem 'passenger'
gem 'algoliasearch-rails', '~>1.11.9'
gem 'google-api-client'

# Database
gem 'pg'

gem 'actionpack-page_caching'
# Lets you access the version of the deploy on Heroku
# Mainly used for caching: see:  config/bust_http_cache.rb
gem 'heroku-api'
gem 'bust_rails_etags'          # https://github.com/n8/bust_rails_etags
gem 'bugsnag'         , '~>2.6.0'

gem 'paypal-recurring', '~>1.1.0'

# For pagination
gem 'kaminari', '~> 0.15.1'

# Monitoring
gem 'newrelic_rpm'          , '~>3.6.8.164'

gem 'highrise'

# Used for the blog. Lets us have coursavenue.com/blog
gem 'rack-reverse-proxy',  require: 'rack/reverse_proxy'
gem 'rack-cors',           require: 'rack/cors'

# Formats numbers and prices regarding the locale
# https://github.com/carlosantoniodasilva/i18n_alchemy
gem 'i18n_alchemy', '~>0.2.1'

# Caching
gem 'memcachier'
gem 'dalli'                     , '~>2.6.4'

# Non stored hash models
# See Level and Audience model
gem 'active_hash'               , '~>1.4.0'

# Transform urls into images, videos etc. Used in medias.
gem 'auto_html'                 , '~>1.6.2'

# Must be before jobs
gem 'protected_attributes'      , '~>1.0.8'

# Queue of jobs
gem 'delayed_job'               , '~>4.0.2'#, git: 'git://github.com/nim1989/delayed_job.git'
gem 'delayed_job_active_record' , '~>4.0.1'
gem 'daemons'                   , '~>1.1.9'
# Needed for hirefire to handle to access to jobs count
gem 'hirefire-resource'

gem 'carrierwave'               , '~>0.10.0'
gem 'carrierwave-imageoptimizer', '~>1.2.1'
gem 'cloudinary'                , '~>1.0.78'

# Handle paperclip in background
gem 'delayed_paperclip'         , '~>2.8.0'
# Show progress bars in scripts
gem 'progress_bar'              , '~>1.0.3'

# For image handling
gem 'paperclip'                 , '~>4.1.1'

# For handy SQL queries
# gem 'squeel'                    , '~>1.1.1'

# For having models acting like trees
gem 'ancestry'                  , '~>2.1.0'

# Nice helper to use google maps
gem 'gmaps4rails'               , '~>2.1.2'
# Helper methods for geolocations
gem 'geocoder'                  , '~>1.2.4'
# To have model serializers apart from models
gem 'active_model_serializers'  , '0.8.3'

# Generate slugs for records
gem 'friendly_id'               , '~>5.0.4'
# Handy forms
gem 'simple_form'               , '~>3.1.0'
# Dry the controllers
gem 'inherited_resources'       , '~>1.4.1'

# For messaging
gem 'mailboxer'                 , '~> 0.12.1'

# For authorizations
gem 'cancancan'                 , '~>1.9.2'
# gem 'cancan'                    , '~>1.6.10'
# For authentication
gem 'devise'                    , '~>3.2.4'
# For facebook connect or more
gem 'omniauth-facebook'         , '~>2.0.0'
gem 'omniauth'                  , '~>1.2.2'
# A full-stack Facebook Graph API wrapper in Ruby.
gem 'fb_graph'                  , '~>2.7.10'
gem 'certified'                 , '~>0.1.1'

# Search engine
gem 'sunspot'                   , '~>2.1.1'
# Add solr server for development
gem 'sunspot_solr'              , '~>2.1.1', group: :development
gem 'sunspot_rails'             , '~>2.1.1'
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
gem 'gibbon'                    , '~>1.1.3'

# Transform external CSS stylesheets into inline CSS for emails
gem 'roadie'                    , '~>3.0.3'
gem 'roadie-rails'              , '~>1.0.4'

# See issue: https://github.com/leshill/handlebars_assets/pull/46
gem 'handlebars_assets'         , '~>0.20.1'#, git: 'git://github.com/variousauthors/handlebars_assets.git'
# Decorator
gem 'draper'                    , '~>1.4.0'
# allows sharing of handlebars templates
gem 'sht_rails'
gem 'sass-rails'                , '~>4.0.3'
gem 'haml'                      , '~>4.0.3'
gem 'uglifier'                  , '>= 1.0.3'
gem 'js-routes'                 , '~>0.9.8'

gem 'activesupport-json_encoder', '~> 1.1.0'

# Load FontAwesome
gem 'font-awesome-rails'        , '~>4.1.0.0'
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
gem 'roo'                       , '~>1.13.2'

# XLSX spreadsheet generation
gem 'axlsx'                     , '~> 2.0.1'

# Rack::UTF8Sanitizer is a Rack middleware which cleans up invalid UTF8 characters in request URI and headers.
# https://github.com/whitequark/rack-utf8_sanitizer
gem 'rack-utf8_sanitizer'       , '~> 1.1.0'

# Use ckeditor for post body
gem 'ckeditor'                  , '~> 4.1.0'#, git: 'git://github.com/nim1989/ckeditor.git'

group :production, :staging do
  gem 'execjs'                    , '~>2.0.2'
  gem 'rails_12factor'            , '~> 0.0.3'
  # Sync assets to S3 and CloudFront
  gem 'asset_sync'                , '~>1.1.0'
  # Enable gzip compression on heroku, but don't compress images
  # gem 'heroku_rails_deflate'      , '~>1.0.3'
  # gem 'rack-zippy'
  gem 'heroku-deflater'
  # gem 'sprockets-image_compressor', '~>0.3.0'
  gem 'htmlcompressor'            , '~>0.1.2'
  gem 'image_optim'               , '~>0.19.1'
  gem 'image_optim_pack'          , '~>0.2.0.20141210'
  gem 'paperclip-optimizer'       , '2.0.0.beta.2'
end

group :test do
  gem 'rspec',              '~> 3.1.0'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'rspec-core',         '~> 3.1.7'
  gem 'rspec-rails',        '~> 3.1.0'
  gem 'faker',              '~> 1.4.3'
  gem 'simplecov',          '~> 0.9.1'
  gem 'database_cleaner',   '~> 1.2.0'
  gem 'capybara',           '~> 2.2.1'
  gem 'rspec-instafail',    '~> 0.2.5'
  gem 'mongoid-rspec',      '~> 2.0.0.rc1'
end

group :development do
  gem 'rails_best_practices', require: false
  gem 'ruby-prof'
  # Speed up slow Rails development mode
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git'
  # Guard::Pow automatically manage Pow applications restart
  gem 'guard-pow', require: false
  # Removes useless logging in dev.
  gem 'fontcustom'
  gem 'brakeman'                , '~>2.3.1'
  gem 'rubocop'                 , '~>0.18.1', require: false

  # Removes useless logging in dev.
  gem 'quiet_assets', '~>1.0.3'

  # Show errors nicely
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'awesome_print'
  gem 'meta_request', '~>0.3.0'
  gem 'pry-rails'
end

group :development, :test do
  # Debugger
  gem 'byebug'
  # Permits to travel in the past
  gem 'delorean'
end

gem 'dotenv-rails'

gem 'rmagick', '~>2.13.3', require: 'RMagick'

# Rails 4 upgrade
gem 'actionpack-action_caching', '~>1.0.0'

# Use mongoid for statistics
gem 'mongoid'                  , '~>4.0.0'

# ActiveRecord Caching
gem 'identity_cache'           , '~> 0.2.2'
gem 'cityhash'                 , '~> 0.8.1'

# JS heavy pages pre-rendering
gem 'prerender_rails'          , '~> 1.1.1'

# Track envents starting in the App
gem 'mixpanel-ruby'

# Email reception
gem 'griddler'         , '~> 1.1.0'
gem 'griddler-mandrill', '~> 1.0.1'

# Send (and receive) SMS
gem 'nexmo', '~> 2.0.0'

group :development do
  # Must be loaded after mongo
  gem 'bullet'                , '~>4.14.0'
end

# For Traceview in Heroku
gem 'oboe-heroku', '~>0.9.16.1'

# PDF generation for orders
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary', require: false

# Contact importing
gem 'omnicontacts', '~> 0.3.5'
