require 'csv'
require 'open-uri'

# https://gist.github.com/aliou/065689914b6677cfb06c
namespace :import do
  namespace :metro do
    desc 'Import Metro Lines'
    task :lines => :environment do
      METRO_LINES = 'https://gist.githubusercontent.com/CoursAvenue/6e3566f39793d268fb10/raw/14469c35b057f8fd6c3f4fa1cef99af190d48af5/metro-lines.json'
      lines_data = JSON.parse(open(METRO_LINES).read)

      lines = Ratp::Line.create(lines_data)
      puts 'Metro lines successfully created.'
    end

    desc 'Import Metro Stops'
    task :stops => :environment do
      if Ratp::Line.count == 0
        puts 'No Metro lines found. Make sure to run `rake import:metro:lines` and rerun this.'
        next
      end

      METRO_STOPS = 'https://gist.githubusercontent.com/CoursAvenue/0aa9d3d490a357179c4d/raw/2c27b51bb85d199d090e46ba68dfea545e8fe9c3/metro-stops.json'
      stops_data = JSON.parse(open(METRO_STOPS).read)
      bar = ProgressBar.new(302)

      stops = stops_data.each do |stop|
        # Create the stop.
        s = Ratp::Stop.create(name: stop['name'], latitude: stop['latitude'], longitude: stop['longitude'], description: stop['description'])

        # Adding the stop to its lines.
        stop['lines'].each do |position|
          l = Ratp::Line.where(slug: position['line']).first
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
