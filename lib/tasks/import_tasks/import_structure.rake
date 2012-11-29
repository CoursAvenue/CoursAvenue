# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
require 'debugger'

namespace :import do
  def structure_hash_from_row(row)
    {
      name:                          row[0],
      name_2:                        row[5],
      structure_type:                row[3],

      has_multiple_place:           (row[4] == 'X' ? true : false),

      street:                        row[6],
      zip_code:                      row[7],
      adress_info:                   row[8],

      closed_days:                   row[9],
      has_handicap_access:           row[10],
      is_professional:              (row[11] == 'X' ? true : false),
      nb_room:                       row[12],
      website:                       row[14],
      newsletter_address:            row[15],

      online_reservation_website:    row[16],
      onlne_reservation_mandatory:  (row[18] == 'X' ? true : false),
      # annual_membership_mandatory:   row[]

      # location_room_number:          row[]

      # annual_price_adult:            row[],
      # annual_price_child:            row[],
      # has_trial_lesson:              row[],
      # trial_lesson_info:             row[],
      # trial_lesson_price:            row[],
      # trial_lesson_info_2:           row[],
      # annual_membership_mandatory:   row[],
      # registration_info:             row[],
      # canceleable_without_fee:       row[],
      # nb_days_before_cancelation:    row[],
      # phone_number:                  row[],
      # mobile_phone_number:           row[],
      # email_address:                 row[],
      # email_address_2:               row[],
      # contact_name:                  row[],
      # accepts_holiday_vouchers:      row[],
      # accepts_ancv_sports_coupon:    row[],
      # accepts_leisure_tickets:       row[],
      # accepts_afdas_funding:         row[],
      # accepts_dif_funding:           row[],
    }
  end

  # Use rake "import:structures[Path to CSV]"
  desc 'Import structures'
  task :structures, [:filename] => :environment do |t, args|
    file_name = args.filename

    puts "Importing: #{file_name}"
    csv_text = File.read(file_name)
    csv = CSV.parse(csv_text)
    csv.each_with_index do |row, i|
      next if i == 0
      row = structure_hash_from_row(row)
      Structure.create(row)
    end
  end
end
