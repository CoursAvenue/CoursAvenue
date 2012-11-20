# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
require 'debugger'

namespace :import do
  def structure_hash_from_row(row)
    {
      name:                          row[0],
      structure_type:                row[3],
      street:                        row[6],
      zip_code:                      row[7],
      adress_info:                   row[8],
      closed_days:                   row[11],
      has_handicap_access:           row[12],
      nb_room:                       row[14],
      website:                       row[16],
      newsletter_address:            row[17],
      online_reservation:            row[18]
      # annual_membership_mandatory:   row[],
      # location_room_number:          row[],
      # is_professional:               row[],
      # annual_price_adult:            row[],
      # annual_price_child:            row[],
      # onlne_reservation_mandatory:   row[],
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
      # has_multiple_plac:             row[],
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
