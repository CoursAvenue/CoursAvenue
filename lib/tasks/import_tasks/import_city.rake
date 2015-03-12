# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def cities_hash_from_row(row)
    {
      iso_code:        row[0],
      zip_code:        row[1],
      name:            row[2],
      region_name:     row[3],
      region_code:     row[4],
      department_name: row[5],
      department_code: row[6],
      commune_name:    row[7],
      commune_code:    row[8],
      latitude:        row[9],
      longitude:       row[10],
      acuracy:         row[11]
    }
  end

  # Use rake "import:cities[Path to TXT]"
  desc 'Import City from TXT'
  task :cities, [:filename] => :environment do |t, args|
    file_name = args.filename || 'Export/FR.txt'
    # City.delete_all
    bar = ProgressBar.new( 51129 )
    # csv_text = File.read(file_name)
    # csv = CSV.parse(csv_text, { col_sep: "\t" })
    # csv.each_with_index do |row, i|
    #   City.create(cities_hash_from_row(row))
    # end

    CSV.foreach(file_name, { col_sep: "\t" }) do |row|
      city = City.where(name: cities_hash_from_row(row)[:name]).first
      if city.nil?
        puts cities_hash_from_row(row)[:name]
        city = City.create(cities_hash_from_row(row))
        next
      end
      city.associated_zip_codes ||= []
      city.associated_zip_codes = city.associated_zip_codes + [cities_hash_from_row(row)[:zip_code].gsub(/\D/, '')]
      city.associated_zip_codes.uniq!
      city.save
      # City.create(cities_hash_from_row(row))
      bar.increment! 1
    end

  end
end
