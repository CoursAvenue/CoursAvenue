# https://github.com/alexreisner/geocoder

if Rails.env.production?
  Geocoder.configure(

    # geocoding service (see below for supported options):
    # :lookup => :yandex,

    # IP address geocoding service (see below for supported options):
    # :ip_lookup => :maxmind,

    :api_key => ENV['GOOGLE_MAPS_API_KEY'],
    :use_https => true,

    # geocoding service request timeout, in seconds (default 3):
    :timeout => 5,

    # set default units to kilometers:
    :units => :km,

    # caching (see below for details):
    # :cache => Redis.new,
    # :cache_prefix => "..."
  )
else
  Geocoder.configure(
    :units => :km
  )
end
