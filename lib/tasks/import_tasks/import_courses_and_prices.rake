# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
require 'debugger'

namespace :import do
  def course_and_price_hash_from_row(row)
    {
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
      course_class:                                   (row[1] == 'Cours' ? Course::Lesson : Course::Training),
      course: {
        min_age_for_kid:                              row[15],
        max_age_for_kid:                              row[16],
        is_individual:                                (row[3] == 'X' ? true : false),
        lesson_info_1:                                row[11],
        lesson_info_2:                                row[12],
      },

      # Price
      price: {
        individual_course_price:                      row[45],
        annual_price:                                 row[46],
        semester_price:                               row[48],
        trimester_price:                              row[49],
        month_price:                                  row[0],
        week_price:                                   row[0],
        five_lessons_price:                           row[0],
        five_lessons_validity:                        row[0],
        ten_lessons_price:                            row[0],
        ten_lessons_validity:                         row[0],
        twenty_lessons_price:                         row[0],
        twenty_lessons_validity:                      row[0],
        thirty_lessons_price:                         row[0],
        thirty_lessons_validity:                      row[0],
        fourty_lessons_price:                         row[0],
        fourty_lessons_validity:                      row[0],
        fifty_lessons_price:                          row[0],
        fifty_lessons_validity:                       row[0],
        one_lesson_per_week_package_price:            row[48],
        one_lesson_per_week_package_validity:         row[0],
        two_lesson_per_week_package_price:            row[47],
        two_lesson_per_week_package_validity:         row[0],
        unlimited_access_price:                       row[0],
        unlimited_access_validity:                    row[0],
        excluded_lesson_from_unlimited_access_card:   row[0],
        price_info_1:                                 row[0],
        price_info_2:                                 row[0],
        exceptional_offer:                            row[0],
        details_1:                                    row[0],
        details_2:                                    row[0],
        is_free:                                      row[0]
      },

      # Planning
      planning: {
        start_date:                                   row[23],
        start_time:                                   row[22],
        week_day:                                     row[21]#,
        # day_one:                                      row[0],
        # day_one_duration:                             row[0],
        # day_one_start_time:                           row[0],
        # day_two:                                      row[0],
        # day_two_duration:                             row[0],
        # day_two_start_time:                           row[0],
        # day_three:                                    row[0],
        # day_three_duration:                           row[0],
        # day_three_start_time:                         row[0],
        # day_four:                                     row[0],
        # day_four_duration:                            row[0],
        # day_four_start_time:                          row[0],
        # day_five:                                     row[0],
        # day_five_duration:                            row[0],
        # day_five_start_time:                          row[0],
        # duration:                                     row[0],
        # end_date:                                     row[0],
        # end_time:                                     row[0],
        # recurrence:                                   row[0],
        # class_during_holidays:                        row[0]
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
      next if i == 0 # Skipping headers
      row = course_and_price_hash_from_row(row)
      structure = Structure.where{name == row[:structure_name]}.first
      next if structure.blank?
      if row[:discipline_name].blank?
        puts "No discipline, check line #{i}"
      end
      #################################################################### Discipline
      discipline = Discipline.where{name == row[:discipline_name]}.first
      discipline = Discipline.create(name: row[:discipline_name]) if discipline.blank?

      course = row[:course_class].create(row[:course])
      course.discipline = discipline

      #################################################################### Associating audiences
      row[:audiences].each do |key, audience_name|
        audience = Audience.where{name == audience_name}.first
        audience = Audience.create(:name => audience_name) if audience.blank?
        course.audiences << audience
      end

      #################################################################### Associating levels
      row[:levels].each do |key, level_name|
        level = Level.where{name == level_name}.first
        level = Level.create(:name => level_name) if level.blank?
        course.levels << level
      end
      #################################################################### Creating Planning
      planning = Planning.create(row[:planning])
      course.planning = planning
      #################################################################### Creating Price
      price = Price.create(row[:price])
      course.price = price

      structure.courses << course
      structure.save
      course.save
    end
  end
end
