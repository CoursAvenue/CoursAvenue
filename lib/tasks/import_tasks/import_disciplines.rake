# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def disciplines_hash_from_row(row)
    {
      course_group_name:          row[0],
      mother_discipline_name:     row[1],
      discipline_name:            row[2],
      course_group_description:   row[3],
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

      # Create mother discipline if doesn't exists
      mother_discipline = Discipline.where{name == row[:mother_discipline_name]}.first
      mother_discipline = Discipline.create(name: row[:mother_discipline_name]) if mother_discipline.blank?

      if row[:discipline_name].blank?
        discipline = mother_discipline
      else
        discipline = Discipline.where{name == row[:discipline_name]}.first
        # If the discipline doesn't exists, creates it and associate the parent
        if discipline.blank?
          discipline = Discipline.create(name: row[:discipline_name])
          discipline.parent = mother_discipline
          discipline.save
        end
      end

      course_groups = CourseGroup.where{name == row[:course_group_name]}
      next if course_groups.blank?
      course_groups.update_all(discipline_id: discipline.id, description: row[:course_group_description])
    end
  end
end
