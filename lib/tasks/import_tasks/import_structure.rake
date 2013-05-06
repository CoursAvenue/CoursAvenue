# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do
  def structure_hash_from_row(row)
    {
      update:                                        (row[8] == 'CoursAvenue' ? true : false),
      structure_name:                                row[12],
      place_name:                                    row[13] || row[12],

      street:                                        row[14],
      zip_code:                                      row[15] || 75000,
      description:                                   "#{row[16]} #{row[17]}",

      website:                                       row[18],
      phone_number:                                  row[19],
      mobile_phone_number:                           row[20],
      email_address:                                 row[21],

      subjects:                                      [row[24],row[25],row[26],row[27], row[28]],
    }
  end

  # Use rake "import:structures[Path to CSV]"
  desc 'Import structures'
  task :structures, [:filename] => :environment do |t, args|
    file_name = args.filename || 'Export/structures.csv'

    puts "Importing: #{file_name}"
    csv_text = File.read(file_name)
    csv      = CSV.parse(csv_text)
    all_level_id      = Level.all_levels.id
    adult_audience_id = Audience.adult.id
    csv.each_with_index do |row, i|
      next if i == 0

      structure_info = structure_hash_from_row(row)
      next if structure_info[:structure_name].nil?
      structure = Structure.where{name == structure_info[:structure_name]}.first
      city      = City.where{zip_code == structure_info[:zip_code]}.first
      if structure.nil?
        structure      = Structure.new(name: structure_info[:structure_name], street: structure_info[:street], zip_code: structure_info[:zip_code])
        structure.city = city
        structure.save
      end
      place = nil
      if structure_info[:update]
        place = structure.places.where(name: structure_info[:place_name]).first
      end
      if place.nil?
        place          = structure.places.build(name: structure_info[:place_name], street: structure_info[:street], zip_code: structure_info[:zip_code])
        place.city     = city
      end
      structure.phone_number          = structure_info[:phone_number]
      structure.mobile_phone_number   = structure_info[:mobile_phone_number]
      place.contact_phone             = structure_info[:phone_number]
      place.contact_mobile_phone      = structure_info[:mobile_phone_number]

      courses = []
      subjects = structure_info[:subjects].compact.each do |subject_name|
        subject_name = subject_name.split(' - ').last
        subject = Subject.where(name: subject_name).first
        courses << place.courses.build(name: subject_name, subject_ids: [subject.id], type: 'Course::Lesson', level_ids: [all_level_id], audience_ids: [adult_audience_id])
      end

      structure.save
      place.save
      courses.map(&:save)
    end
  end
end
