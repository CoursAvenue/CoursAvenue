require 'highrise'

Highrise::Base.site = 'https://coursavenue1.highrisehq.com'
Highrise::Base.user = ENV['HIGHRISE_API_KEY']
Highrise::Base.format = :xml
