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
        contact_phone:            row[18],
        contact_mail:             row[19],
        info:                     row[12],
        minimum_price:            row[14],
        maximum_price:            row[15],
        price_info:               row[17],
        is_duty_free:            (row[16] == 'HT' ? true : false),
        regular_renting_price:    row[13],
        surface:                  row[3],
        has_bars:                 (row[4]  == 'X' ? true : false),
        has_mirrors:              (row[5]  == 'X' ? true : false),
        has_sound:                (row[6]  == 'X' ? true : false),
        has_carpets:              (row[7]  == 'X' ? true : false),
        has_parquet:              (row[8]  == 'X' ? true : false),
        has_piano:                (row[9]  == 'X' ? true : false),
        has_recording_studio:     (row[10] == 'X' ? true : false),
        has_cloakroom:            (row[11] == 'X' ? true : false)
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
