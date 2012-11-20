# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
require 'debugger'

namespace :import do
  def course_and_price_hash_from_row(row)
  course_and_price_hash_from_row =  {
      structure_name:                                 row[0],

      discipline_name:                                row[2],
      audiences: {
        audience_1:                                   row[5],
        audience_2:                                   row[6],
        audience_3:                                   row[7],
      },

      levels: {
        level_1:                                      row[13],
        level_2:                                      row[14]
      },

      # Course
      course: {
        course_class:                                 (row[1] == 'Cours' ? Course::Lesson : Course::Training),
        min_age_for_kid:                              row[15],
        max_age_for_kid:                              row[16],
        is_individual:                                (row[3] == 'X' ? true : false),
        lesson_info_1:                                row[11],
        lesson_info_2:                                row[12],
      },

      # Price
      price: {
        individual_course_prce:                       row[],
        annual_price:                                 row[],
        trimester_price:                              row[],
        month_price:                                  row[],
        week_price:                                   row[],
        five_lessons_price:                           row[],
        five_lessons_validity:                        row[],
        ten_lessons_price:                            row[],
        ten_lessons_validity:                         row[],
        twenty_lessons_price:                         row[],
        twenty_lessons_validity:                      row[],
        thirty_lessons_price:                         row[],
        thirty_lessons_validity:                      row[],
        fourty_lessons_price:                         row[],
        fourty_lessons_validity:                      row[],
        fifty_lessons_price:                          row[],
        fifty_lessons_validity:                       row[],
        one_lesson_per_week_package_price:            row[],
        one_lesson_per_week_package_validity:         row[],
        two_lesson_per_week_package_price:            row[],
        two_lesson_per_week_package_validity:         row[],
        unlimited_access_price:                       row[],
        unlimited_access_validity:                    row[],
        excluded_lesson_from_unlimited_access_car:    row[],
        price_info_1:                                 row[],
        price_info_2:                                 row[],
        exceptional_offer:                            row[],
        details_1:                                    row[],
        details_2:                                    row[],
        is_free:                                      row[]
      },

      # Planning
      planning: {

      }
    }
  end

  # Use rake "import:renting_rooms[Path to CSV]"
  desc 'Import Renting rooms from CSV'
  task :courses_prices_and_plannings, [:filename] => :environment do |t, args|
    file_name = args.filename

    puts "Importing: #{file_name}"
    csv_text = File.read(file_name)
    csv = CSV.parse(csv_text)

    csv.each_with_index do |row, i|
      next if i == 0
      row = renting_rooms_hash_from_row(row)
      structure = Structure.where{name == row[:structure_name]}.first

      next if structure.blank?

      discipline = Discipline.where{name == row[:discipline_name]}.first

      discipline = Discipline.create(name: row[:discipline_name]) if discipline.blank?
      course = row[:course_class].create(row[:course])
      course.discipline = discipline
      row[:audiences].each do |audience_name|
        audience = Audience.where{name == audience_name}.first
        audience = Audience.create(:name => audience_name) if audience.blank?
        course.audiences << audience
      end
      row[:levels].each do |level_name|
        level = Level.where{name == level_name}.first
        level = Level.create(:name => level_name) if level.blank?
        course.levels << level
      end

    end
  end
end
