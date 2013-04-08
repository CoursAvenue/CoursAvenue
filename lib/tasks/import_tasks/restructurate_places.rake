# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :restructurate do
  def structure_place_hash_from_row(row)
    {
      structure_name:        row[0],
      new_structure_name:    row[1],
      new_place_name:        row[2]
    }
  end

  # Use rake "import:structures[Path to CSV]"
  desc 'Import structures'
  task :structure_places, [:filename] => :environment do |t, args|
    file_name = args.filename || 'Export/structures_places.csv'

    puts "Importing: #{file_name}"
    csv_text = File.read(file_name)
    csv      = CSV.parse(csv_text)
    csv.each_with_index do |row, i|
      next if i == 0
      structure_info = structure_place_hash_from_row(row)
      structure      = Structure.where{name == structure_info[:structure_name]}.first
      place          = Place.where{name == structure_info[:structure_name]}.first
      if structure.nil?
        puts "Not found: #{structure_info[:structure_name]}"
        next
      end
      structure.update_column :name, structure_info[:new_structure_name]
      place.update_column     :name, structure_info[:new_place_name]

    end
  end

  task :merge_structures, [:filename] => :environment do |t, args|
    file_name = args.filename || 'Export/structures.csv'

    puts "Importing: #{file_name}"
    csv_text = File.read(file_name)
    csv      = CSV.parse(csv_text)
    csv.each_with_index do |row, i|
      next if i == 0
      structures      = Structure.where{name == row[0]}
      main_structure  = structures.pop
      structures.each do |structure|
        main_structure_id = main_structure.id
        structure.places.each do |place|
          place.update_column :structure_id, main_structure_id
          place.courses.each do |course|
            course.update_column :structure_id, main_structure_id
          end
        end
        structure.delete
      end

    end
  end
end
