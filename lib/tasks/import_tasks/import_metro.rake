require 'csv'
require 'open-uri'

# https://gist.github.com/aliou/065689914b6677cfb06c
namespace :import do
  namespace :metro do
    desc 'Import Metro Lines'
    task :lines => :environment do
      METRO_LINES = 'https://gist.githubusercontent.com/aliou/065689914b6677cfb06c/raw/56d4a91ba9e314f00dd4b4345db69f4bf775d3b2/metro-lines.json'
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

      METRO_STOPS = 'https://gist.githubusercontent.com/aliou/065689914b6677cfb06c/raw/054f02f40ddcbfb09c138b4f6dda29cdbda20cd4/metro-stops.json'
      stops_data = JSON.parse(open(METRO_STOPS).read)
      bar = ProgressBar.new(302)

      stops = stops_data.each do |stop|
        # Create the stop.
        s = Metro::Stop.create(name: stop['name'], latitude: stop['latitude'], longitude: stop['longitude'], description: stop['description'])

        # Adding the stop to its lines.
        stop['lines'].each do |position|
          l = Metro::Line.where(slug: position['line']).first
          if l.present?
            l.positions.create(line: l, stop: s, position: position['position'])
          end
        end

        bar.increment!(1)
      end
      puts 'Metro stops successfully created.'
    end
  end
end
