require 'csv'
require 'open-uri'

# https://gist.github.com/aliou/065689914b6677cfb06c
namespace :import do
  namespace :metro do
    desc 'Import Metro Lines'
    task :lines => :environment do
      METRO_LINES = 'https://gist.githubusercontent.com/aliou/065689914b6677cfb06c/raw/ede73e485175b80a6bdb27f9ebf5aba8be038ed9/metro-lines.json'
      lines_data = JSON.parse(open(METRO_LINES).read)

      lines = Metro::Line.create(lines_data)
      puts 'Metro lines successfully created.'
    end

    desc 'Import Metro Stops'
    task :stops => :environment do
      if Metro::Line.count == 0
        puts 'No Metro lines found. Make sure to run `rake import:metro:lines` and rerun this.'
        next
      end

      METRO_STOPS = 'https://gist.githubusercontent.com/aliou/065689914b6677cfb06c/raw/0b1b742e3860f63daeb5c1f179774f8b8a43f271/metro-stops.json'
      stops_data = JSON.parse(open(METRO_STOPS).read)
      bar = ProgressBar.new(302)

      stops = stops_data.each do |stop|
        # Create the stop.
        s = Metro::Stop.create(name: stop['name'], latitude: stop['latitude'], longitude: stop['longitude'], description: stop['description'])

        # Adding the stop to its lines.
        stop['lines'].each do |line|
          l = Metro::Line.where(slug: line).first
          if l.present?
            l.stops << s
          end
        end

        bar.increment!(1)
      end
      puts 'Metro stops successfully created.'
    end
  end
end
