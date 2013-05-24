if Rails.env.production?
  require 'heroku-api'

  heroku = Heroku::API.new(:api_key => "9f3f949c46e935d43e966bc37b499971523a3fc7")
  release_version = heroku.get_releases('coursavenue').body.last

  ENV["ETAG_VERSION_ID"] = release_version["name"]
end
