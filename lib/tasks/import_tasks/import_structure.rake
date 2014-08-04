# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do
  def structure_hash_from_row(row)
    return {
        key:        row[0],
        name:       row[1],
        website:    row[2],
        streets:    [row[3], row[6], row[9], row[12], row[15]].compact,
        zip_codes:  [row[4], row[7], row[10], row[13], row[16]].compact,
        city_names: [row[5], row[8], row[11], row[14], row[17]].compact,
        subjects:   [row[18], row[19], row[20], row[21], row[22], row[23], row[24], row[25], row[26], row[27]].compact,
        emails:     [row[28], row[29], row[30], row[31], row[32]].compact,
        phones:     [row[33], row[34], row[35]].compact
      }
  end

  # Use rake "import:structures[Path to CSV]"
  # Use rake import:structures_logo
  desc 'Import structures'
  task :structures_logo, [:filename] => :environment do |t, args|
    # url = 'http://coursavenue-public.s3.amazonaws.com/import_dormants/Midi-Pyrenees.csv'
    url = 'http://coursavenue-public.s3.amazonaws.com/import_dormants/Alpes-Maritimes.csv'
    file = open(url)
    bar = ProgressBar.new file.readlines.size
    CSV.foreach(file, { col_sep: ";" }) do |row|
      if first
        first = false
        next
      end
      bar.increment!
      attributes = structure_hash_from_row(row)
      structure = Structure.where(name: attributes[:name]).order('created_at DESC').first
      next if structure.nil?
      begin
        url = URI.parse("http://coursavenue-public.s3.amazonaws.com/import_dormants/Logos_Alpes-Maritimes/#{attributes[:key]}.png")
        # url = URI.parse("http://coursavenue-public.s3.amazonaws.com/import_dormants/Logos_MidiPyrenees/#{attributes[:key]}.png")
        req = Net::HTTP.new(url.host, url.port)
        res = req.request_head(url.path)
        if res.code == '200'
          structure.logo = url
          structure.save
        end
      rescue Exception => exception
        Bugsnag.notify(exception)
      end
    end
  end

  # Use rake "import:structures[Path to CSV]"
  # Use rake import:structures
  desc 'Import structures'
  task :structures, [:filename] => :environment do |t, args|
    first = true
    # url = 'http://coursavenue-public.s3.amazonaws.com/import_dormants/Midi-Pyrenees.csv'
    url = 'http://coursavenue-public.s3.amazonaws.com/import_dormants/Alpes-Maritimes.csv'
    file = open(url)
    bar = ProgressBar.new file.readlines.size
    CSV.foreach(file, { col_sep: ";" }) do |row|
      if first
        first = false
        next
      end
      bar.increment!
      attributes = structure_hash_from_row(row)
      already_exists = false
      attributes[:emails].each do |email|
        if Admin.where(email: email).any? or Structure.where(contact_email: email).any?
          already_exists = true
          break
        end
      end
      next if already_exists
      # Getting cities
      attributes[:cities] = []
      attributes[:zip_codes].each_with_index do |zip_code, index|
        city = City.where(City.arel_table[:zip_code].matches("%#{zip_code}%")).first
        if city.nil?
          puts zip_code
          puts attributes[:city_names][index]
        end
        attributes[:cities] << city
      end
      places_attributes = []
      attributes[:zip_codes].each_with_index do |zip_code, index|
        next if attributes[:cities][index].nil?
        places_attributes << {
          name: attributes[:cities][index].name,
          street: attributes[:streets][index],
          zip_code: zip_code,
          city_id: attributes[:cities][index].id
        }
      end
      phone_attributes = []
      attributes[:phones].each_with_index do |phone_number|
        phone_number = "0#{phone_number}" unless phone_number.starts_with?('0')
        phone_attributes << { number: phone_number }
      end
      subject_ids = []
      attributes[:subjects].each_with_index do |subject_name|
        subject = Subject.where(Subject.arel_table[:name].matches(subject_name)).first
        if subject.nil?
          puts subject_name
          next
        end
        subject_ids << subject.id
        subject_ids << subject.root.id
      end
      structure = Structure.create(name: attributes[:name],
                                   subject_ids: subject_ids.uniq,
                                   website: attributes[:website],
                                   phone_numbers_attributes: phone_attributes,
                                   places_attributes: places_attributes,
                                   contact_email: attributes[:emails].first,
                                   is_sleeping: true,
                                   other_emails: attributes[:emails][0..-1].join(';'))
      unless structure.persisted?
        puts "#{attributes[:key]} : #{attributes[:name]}\n#{structure.errors.full_messages.to_sentence}\n\n"
      else
        begin
          url = URI.parse("http://coursavenue-public.s3.amazonaws.com/import_dormants/Logos_Alpes-Maritimes/#{attributes[:key]}.png")
          # url = URI.parse("http://coursavenue-public.s3.amazonaws.com/import_dormants/Logos_MidiPyrenees/#{attributes[:key]}.png")
          req = Net::HTTP.new(url.host, url.port)
          res = req.request_head(url.path)
          if res.code == '200'
            structure.logo = url
            structure.save
          end
        rescue Exception => exception
          Bugsnag.notify(exception)
        end
      end
    end
  end
end
