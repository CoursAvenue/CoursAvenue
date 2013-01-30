# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def disciplines_hash_from_row(row)
    {
      course_name:        row[0],
      discipline_name_1:  row[1],
      discipline_name_2:  row[2],
      description:        row[3],
    }
  end
  # Use rake "import:renting_rooms[Path to CSV]"
  desc 'Import Disciplines rooms from CSV'
  task :disciplines, [:filename] => :environment do |t, args|
    file_name = args.filename

    csv_text = File.read(file_name)
    csv = CSV.parse(csv_text)
    csv.each_with_index do |row, i|
      next if i == 0
      row = disciplines_hash_from_row(row)

      next if row[:discipline_name_1].blank?
      course = Course.where{name == row[:course_name]}.first
      next if course.blank?
      discipline_1 = Discipline.where{name == row[:discipline_name_1]}.first
      discipline_2 = Discipline.where{name == row[:discipline_name_2]}.first
      if discipline_1.nil?
        puts "Couldn't find #{row[:discipline_name_1]}"
        next
      end
      course.disciplines << discipline_1
      course.disciplines << discipline_2 unless discipline_2.nil?
      course.description = row[:description] unless row[:description].blank?
      course.save
    end
  end
end
