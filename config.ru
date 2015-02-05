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

use Rack::CanonicalHost do
  case ENV['RACK_ENV'].to_sym
    when :staging then 'staging.coursavenue.com'
    when :production then 'coursavenue.com'
  end
end


run CoursAvenue::Application
