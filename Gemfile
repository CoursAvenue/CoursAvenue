# encoding: utf-8
source 'https://rubygems.org'

ruby '1.9.3'
gem 'rails', '3.2.14'

# Gems used only for assets and not required
# in production environments by default.

# Webserver
gem 'unicorn'
# Database
gem 'pg'

# Lets you access the version of the deploy on Heroku
# Mainly used for caching: see:  config/bust_http_cache.rb
gem 'heroku-api'
gem 'bust_rails_etags'          # https://github.com/n8/bust_rails_etags

# Monitoring
gem 'newrelic_rpm'          , '~> 3.6.6.147'

# Used to update contacts in nutshell CRM
gem 'nutshell-crm'

# Used for the blog. Lets us have coursavenue.com/blog
gem 'rack-reverse-proxy',  require: 'rack/reverse_proxy'
gem 'rack-cors',           require: 'rack/cors'

# Formats numbers and prices regarding the locale
gem 'delocalize', '~> 0.3.1'

# Caching
gem 'memcachier'
gem 'dalli'

# Add plugin to enable copy button
gem 'zeroclipboard-rails'

# Non stored hash models
# See Level and Audience model
gem 'active_hash'               , '~> 1.0.0'

# Transform urls into images, videos etc. Used in medias.
gem 'auto_html'                 , '~> 1.6.0'

# Queue of jobs
gem 'delayed_job_active_record' , '~> 0.4.4'
# Needed for hirefire to handle to access to jobs count
gem 'hirefire-resource'

# Show progress bars in scripts
gem 'progress_bar'

# For pagination
gem 'kaminari'                  , '~>0.14.1'
# For image handling
gem 'paperclip'                 , '~>3.5.1'
gem 'aws-sdk'                   , '~>1.8.0'
# For handy SQL queries
gem 'squeel'                    , '~>1.0.14'
# For having models acting like trees
gem 'ancestry'                  , '~>2.0.0'

# Nice helper to use google maps
gem 'gmaps4rails'               , '~>1.5.6'
# Helper methods for geolocations
gem 'geocoder'                  , '~>1.1.6'
# To have model serializers apart from models
gem 'active_model_serializers'  , '~>0.6.0'

# Generate slugs for records
gem 'friendly_id'               , '~> 4.0.9'
# Handy forms
gem 'simple_form'               , '~> 2.0.4'
# Dry the controllers
gem 'inherited_resources'       , '~> 1.3.1'

# For authorizations
gem 'cancan'                    , '~> 1.6.9'
# For authentication
gem 'devise'                    , '~> 2.2.3'
# Add invitation behavior to devise
gem 'devise_invitable'          , '~> 1.1.5'
# Facebook connect
gem 'omniauth-facebook'         , '~> 1.4.0'
# Helps access to gmail contacts etc.
gem 'omnicontacts'              , '~> 0.3.4'

# For search
gem 'sunspot'                   , '~> 2.0.0'
gem 'sunspot_solr'              , '~> 2.0.0'
gem 'sunspot_rails'             , '~> 2.0.0'
gem 'sunspot-rails-tester'      , '~> 1.0.0'

# Prevent from real deletion
gem 'acts_as_paranoid'          , '~> 0.4.2'

# Helps having a clean ruby sitemap
gem 'sitemap_generator'         , '~> 3.4'
# Mailchimp API
gem 'gibbon'                    , '~> 0.4.6'

# Transform external CSS stylesheets into inline CSS for emails
gem 'roadie', '~> 2.4.1'

group :assets do
  gem 'sass-rails'              , '~> 3.2.4'
  gem 'uglifier'                , '>= 1.0.3'
  gem 'coffee-rails'            , '~> 3.2.1'
end
# gem 'js-routes'                 , '~> 0.9.3'
# Load FontAwesome
gem 'font-awesome-rails'        , '~> 3.2.1.3'
# Load jQuery
gem 'jquery-rails'              , '~> 3.0.4'
# Load Compass utilities
gem 'compass'                   , '~> 0.12.2'
gem 'compass-rails'             , '~> 1.0.3'
# Load Inuit CSS
gem 'compass-inuit'             , '~> 5.0.1'
# Sync assets to S3 and CloudFront
gem 'asset_sync'                , '~> 0.5.4'
# Enable haml
gem 'haml'                      , '~> 3.1.7'

group :production do
  # gem 'therubyracer'
  gem 'execjs'
  gem 'rails_12factor'
end

group :test do
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'rspec-rails'       , '~> 2.13.2'
  gem 'rspec-instafail'   , '~> 0.2.4'
  gem 'forgery'           , '~> 0.5.0'
  gem 'simplecov'         , '~> 0.7.1'
end

group :development do
  # Show errors in a beautiful way
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'awesome_print'
  gem 'meta_request', '0.2.1'
end

group :development, :test do
  gem 'debugger'
  # Permits to travel in the past
  gem 'delorean'
end

# Helps see which gems are not necessessary for boot time
gem 'gem_bench', :group => :console

