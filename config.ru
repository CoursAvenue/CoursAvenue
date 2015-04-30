# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require "rack-timeout"
require 'rack/cors'

# Call as early as possible so rack-timeout runs before other middleware.
use Rack::Timeout
use Rack::Deflater
use Rack::Attack

Rack::Timeout.timeout = 30

use Rack::Cors do
  allow do
    origins '*'
    resource '/fonts/*', headers: :any, methods: :get
  end
end

# if ENV['RACK_ENV'] == 'production'# or ENV['RACK_ENV'] == 'staging'
#   use Rack::CanonicalHost, 'www.coursavenue.com', ignore: ['pro.coursavenue.com']
# end

run CoursAvenue::Application
