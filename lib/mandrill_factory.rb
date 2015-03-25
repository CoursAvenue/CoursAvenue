require 'mandrill'

class MandrillFactory
  def self.client
    if Rails.env.production?
      Mandrill::API.new(ENV['MANDRILL_API_KEY'])
    else
      FakeMandrill::Client.new
    end
  end
end
