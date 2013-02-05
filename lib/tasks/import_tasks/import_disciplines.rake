# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def subjects_hash_from_row(row)
    {
      course_name:     row[0],
      subject_name_1:  row[1],
      subject_name_2:  row[2],
      description:     row[3],
    }
  end
  # Use rake "import:renting_rooms[Path to CSV]"
  desc 'Import Subjects rooms from CSV'
  task :subjects, [:filename] => :environment do |t, args|
    file_name = args.filename

    csv_text = File.read(file_name)
    csv = CSV.parse(csv_text)
    csv.each_with_index do |row, i|
      next if i == 0
      row = subjects_hash_from_row(row)

      next if row[:subject_name_1].blank?
      courses = Course.where{name =~ row[:course_name]}
      if courses.empty?
        puts "Can't find #{row[:course_name]}"
        next
      end
      subject_1 = Subject.where{name == row[:subject_name_1]}.first
      subject_2 = Subject.where{name == row[:subject_name_2]}.first
      if subject_1.nil?
        puts "Couldn't find #{row[:subject_name_1]}"
        next
      end
      courses.each do |course|
        course.subjects << subject_1
        course.subjects << subject_2     unless subject_2.nil?
        course.description = row[:description] unless row[:description].blank?
        course.save
      end
    end
  end
end
