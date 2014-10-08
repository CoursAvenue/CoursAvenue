Cloudinary.config do |config|
  config.cdn_subdomain = true
  config.cloud_name    = ENV['CLOUDINARY_CLOUD_NAME']
  config.api_key       = ENV['CLOUDINARY_API_KEY']
  config.api_secret    = ENV['CLOUDINARY_SECRET']
  config.secure        = true
  config.sign_url      = true
end
