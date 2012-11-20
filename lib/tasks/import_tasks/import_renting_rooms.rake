# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
require 'debugger'

namespace :import do
  def renting_rooms_hash_from_row(row)
    {
      structure_name:             row[0],
      renting_room: {
        name:                     row[2],
        contact:                  row[16],
        info:                     row[11],
        minimum_price:            row[13],
        maximum_price:            row[14],
        price_info:               row[15],
        regular_renting_price:    row[12],
        surface:                  row[3],
        has_bars:                 (row[4] == 'Oui' ? true : false),
        has_mirrors:              (row[5] == 'Oui' ? true : false),
        has_sound:                (row[6] == 'Oui' ? true : false),
        has_carpets:              (row[7] == 'Oui' ? true : false),
        has_parquet:              (row[8] == 'Oui' ? true : false),
        has_piano:                (row[9] == 'Oui' ? true : false),
        has_cloakroom:            (row[10] == 'Oui' ? true : false)
      }
    }
  end

  # Use rake "import:renting_rooms[Path to CSV]"
  desc 'Import Renting rooms from CSV'
  task :renting_rooms, [:filename] => :environment do |t, args|
    file_name = args.filename

    puts "Importing: #{file_name}"
    csv_text = File.read(file_name)
    csv = CSV.parse(csv_text)
    csv.each_with_index do |row, i|
      next if i == 0
      row = renting_rooms_hash_from_row(row)
      structure = Structure.where{name == row[:structure_name]}.first
      next if structure.blank?
      renting_room = RentingRoom.create(row[:renting_room])
      renting_room.structure = structure
      renting_room.save
    end
  end
end
