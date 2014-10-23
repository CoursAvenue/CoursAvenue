namespace :scheduler do

  desc 'Ping the prerender service'
  task :ping => :environment do |t, args|
    if ENV['PRERENDER_SERVICE_URL'].present?
      uri = URI.parse(ENV['PRERENDER_SERVICE_URL'])
      Net::HTTP.get_response(uri)
    end
  end
end
