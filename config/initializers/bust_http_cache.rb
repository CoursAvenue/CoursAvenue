if Rails.env.production? or Rails.env.staging?
  require 'heroku-api'

  heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
  release_version = heroku.get_releases('coursavenue').body.last

  ENV["ETAG_VERSION_ID"] = release_version["name"]
end
