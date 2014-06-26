# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require "rack-timeout"

# Call as early as possible so rack-timeout runs before other middleware.
use Rack::Timeout
use Rack::Deflater
use Rack::Attack

Rack::Timeout.timeout = 30

# For blog url
# See: http://rywalker.com/setting-up-a-wordpress-blog-on-heroku-as-a-subdirectory-of-a-rails-app-also-hosted-on-heroku
use Rack::ReverseProxy do
  reverse_proxy(/^\/blog(\/.*)$/,
    'http://blog.coursavenue.com$1',
    opts = {:preserve_host => true})
end

# Allow font files to be loaded from anywhere (for loading webfonts in Firefox)
# require 'rack/cors'
# use Rack::Cors do
#   allow do
#     origins '*'
#     resource '/fonts/*', :headers => :any, :methods => :get
#   end
# end

run CoursAvenue::Application

