# encoding: utf-8
source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '4.0.0'

# Webserver
gem 'unicorn'
# Database
gem 'pg'

# Lets you access the version of the deploy on Heroku
# Mainly used for caching: see:  config/bust_http_cache.rb
gem 'heroku-api'
gem 'bust_rails_etags'          # https://github.com/n8/bust_rails_etags

# Monitoring
gem 'newrelic_rpm'          , '~>3.6.8.164'

# Used to update contacts in nutshell CRM
gem 'nutshell-crm'

# Used for the blog. Lets us have coursavenue.com/blog
gem 'rack-reverse-proxy',  require: 'rack/reverse_proxy'
gem 'rack-cors',           require: 'rack/cors'

# Formats numbers and prices regarding the locale
# TODO Fix this gem
# gem 'delocalize', '~>0.3.2'

# Caching
gem 'memcachier'
gem 'dalli'      , '~>2.6.4'

# Add plugin to enable copy button
gem 'zeroclipboard-rails'

# Non stored hash models
# See Level and Audience model
gem 'active_hash'               , '~>1.2.0'

# Transform urls into images, videos etc. Used in medias.
gem 'auto_html'                 , '~>1.6.0'

# Queue of jobs
gem 'delayed_job_active_record' , '~>4.0.0'
# Needed for hirefire to handle to access to jobs count
gem 'hirefire-resource'

# Show progress bars in scripts
gem 'progress_bar'              , '~>1.0.0'

# For pagination
gem 'kaminari'                  , '~>0.14.1'
# For image handling
gem 'paperclip'                 , '~>3.5.1'
# For uploading to amazon CDN
# TODO
# gem 'aws-sdk'                   , '~>1.21.0'

# For handy SQL queries
gem 'squeel'                    , '~>1.1.1'
# For having models acting like trees
gem 'ancestry'                  , '~>2.0.0'

# Nice helper to use google maps
gem 'gmaps4rails'               , '~>1.5.6'
# Helper methods for geolocations
gem 'geocoder'                  , '~>1.1.8'
# To have model serializers apart from models
gem 'active_model_serializers'  , '~>0.8.1'

# Generate slugs for records
gem 'friendly_id'               , '~>5.0.0.rc2'
# Handy forms
gem 'simple_form'               , '~>3.0.0'
# Dry the controllers
gem 'inherited_resources'       , '~>1.3.1'

# For authorizations
gem 'cancan'                    , '~>1.6.9'
# For authentication
gem 'devise'                    , '~>3.1.1'
# Facebook connect
gem 'omniauth-facebook'         , '~>1.4.0'
# Helps access to gmail contacts etc.
gem 'omnicontacts'              , '~>0.3.4'

# Search engine
gem 'sunspot'                   , '~>2.0.0'
# Add solr server for development
gem 'sunspot_solr'              , '~>2.0.0', group: :development
gem 'sunspot_rails'             , '~>2.0.0'
gem 'sunspot-rails-tester'      , '~>1.0.0'

# Prevent from real deletion
# acts_as_paranoid
gem 'paranoia'                  , '~>2.0'

# Helps having a clean ruby sitemap
gem 'sitemap_generator'         , '~>4.2.0'
# Mailchimp API
gem 'gibbon'                    , '~>1.0.4'

# Transform external CSS stylesheets into inline CSS for emails
gem 'roadie'                    , '~>2.4.2'

# Includes Backbone
gem 'railsy_backbone'           , '~>0.0.5'
# Includes Backbone Marionette
gem 'marionette-rails'          , '~>1.1.0'
# Includes bacbone.relational
gem 'backbone-relational-rails' , '~>0.8.6'
gem 'handlebars_assets'         , '~>0.14.1'
gem 'sass-rails'                , '~>4.0.0'
gem 'haml'                      , '~>4.0.3'
gem 'uglifier'                  , '>= 1.0.3'
gem 'coffee-rails'              , '~>4.0.0'
# gem 'js-routes'                 , '~>0.9.3'

# Load FontAwesome
gem 'font-awesome-rails'        , '~>3.2.1.3'
# Load jQuery
gem 'jquery-rails'              , '~>3.0.4'
# Load Compass utilities
gem 'compass'                   , '~>0.12.2'
gem 'compass-rails'             , '~>2.0.alpha.0'
# Load Inuit CSS
gem 'compass-inuit'             , '~>5.0.2'
# Sync assets to S3 and CloudFront
gem 'asset_sync'                , '~>1.0.0'
# Enable haml

gem 'turbolinks'
gem 'jquery-turbolinks'

group :production do
  # gem 'therubyracer'
  gem 'execjs'
  gem 'rails_12factor'
end

group :test do
  gem 'factory_girl_rails', '~>4.2.1'
  gem 'rspec-rails'       , '~>2.14.0'
  gem 'rspec-instafail'   , '~>0.2.4'
  gem 'forgery'           , '~>0.5.0'
  gem 'simplecov'         , '~>0.7.1'
end

group :development do
  # Show errors in a beautiful way
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'awesome_print'
  gem 'meta_request', '0.2.6'
end

group :development, :test do
  # gem 'debugger' # this is causing problems for Andre
  # Permits to travel in the past
  gem 'delorean'
end

# Helps see which gems are not necessessary for boot time
gem 'gem_bench', :group => :console

# Rails 4 upgrade
gem 'protected_attributes'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
