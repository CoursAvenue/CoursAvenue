# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do
  def structure_hash_from_row(row)
    {
        name:       row[0],
        website:    row[1],
        street:     row[2],
        zip_code:   row[3],
        city:       row[4],
        street_2:   row[5],
        zip_code_2: row[6],
        city_2:     row[7],
        street_3:   row[8],
        zip_code_3: row[9],
        city_3:     row[10],
        subjects:   [row[11], row[12], row[13], row[14], row[15], row[16], row[17], row[18], row[19], row[20]].compact,
        emails:     [row[21], row[22], row[23], row[24], row[25]].compact,
        telephones: [row[26], row[27], row[28]].compact
    }
  end

  # Use rake "import:structures[Path to CSV]"
  desc 'Import structures'
  task :structures, [:filename] => :environment do |t, args|
    file_name = args.filename || 'Export/paris_15avril2014.xlsx'
    excel = Roo::Excelx.new(file_name)
    puts "Importing: #{file_name}"
    10000.times do |index|
      # index in xlsx starts at 1
      index += 1
      excel.row(index)
    end
  end
end
