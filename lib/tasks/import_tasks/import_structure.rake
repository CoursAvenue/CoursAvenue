# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do
  def structure_hash_from_row(row)
    {
      name:                                          row[0],
      place_name:                                        row[5],
      structure_type:                                row[3],

      street:                                        row[6],
      zip_code:                                      row[7] || 75000,
      adress_info:                                   row[8],

      has_handicap_access:                          (row[10] == 'X' ? true : false),
      is_professional:                              (row[11] == 'X' ? true : false),
      nb_room:                                       row[12],
      website:                                       row[14],

      registration_info:                             row[21],

      has_registration_form:                        (row[22] == 'X' ? true : false),
      needs_photo_id_for_registration:              (row[23] == 'X' ? true : false),
      needs_id_copy_for_registration:               (row[24] == 'X' ? true : false),
      needs_medical_certificate_for_registration:   (row[26] == 'X' ? true : false),
      needs_insurance_attestation_for_registration: (row[27] == 'X' ? true : false),

      phone_number:                                  row[29],
      mobile_phone_number:                           row[30],
      email_address:                                 row[31],
      accepts_holiday_vouchers:                      row[34],
      accepts_ancv_sports_coupon:                   (row[35] == 'X' ? true : false),
      accepts_leisure_tickets:                      (row[36] == 'X' ? true : false),
      accepts_afdas_funding:                        (row[37] == 'X' ? true : false),
      accepts_dif_funding:                          (row[38] == 'X' ? true : false),
      accepts_cif_funding:                          (row[39] == 'X' ? true : false),
      info:                                          row[40],
    }
  end

  # Use rake "import:structures[Path to CSV]"
  desc 'Import structures'
  task :structures, [:filename] => :environment do |t, args|
    file_name = args.filename

    puts "Importing: #{file_name}"
    csv_text = File.read(file_name)
    csv      = CSV.parse(csv_text)
    paris    = City.where{name == 'Paris'}.first
    csv.each_with_index do |row, i|
      next if i == 0
      structure_info = structure_hash_from_row(row)
      structure      = Structure.new(structure_info)
      structure.city = paris
      structure.save
    end
    puts "#{Structure.count} structures importés"
  end
end
