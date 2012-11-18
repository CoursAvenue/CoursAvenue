# -*- encoding : utf-8 -*-

# Import all structures from CSV
require 'rake/clean'
require 'csv'
require 'debugger'

# Use rake "import_structures[Path to CSV]"
desc 'Import structures'
task :import_structures, [:filename] => :environment do |t, args|
  file_name = args.filename

  puts "Importing: #{file_name}"

  # csv_text = File.read('...')
  # csv = CSV.parse(csv_text, :headers => true)
  # csv.each do |row|
  #   row = row.to_hash.with_indifferent_access
  #   Moulding.create!(row.to_hash.symbolize_keys)
  # end

  CSV.foreach(file_name) do |row|
  end
end



