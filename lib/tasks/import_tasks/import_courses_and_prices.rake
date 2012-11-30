# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
require 'debugger'

namespace :import do

  def course_group_class(name)
    case name
    when 'Cours'
      class_name = CourseGroup::Lesson
    when 'Stage'
      class_name = CourseGroup::Training
    when 'Cours-atelier'
      class_name = CourseGroup::Workshop
    else
      nil
    end
  end
  def level_name(name)
    case name
    when 'TN'
      'level.all'
    when 'Ini'
      'level.initiation'
    when 'D'
      'level.beginner'
    when 'I'
      'level.intermediate'
    when 'M'
      'level.average'
    when 'A'
      'level.advanced'
    when 'C'
      'level.confirmed'
    else
      nil
    end
  end

  def audience_name(name)
    case name
    when 'Enfant'
      'audience.kid'
    when 'Ado'
      'audience.teenage'
    when 'Adulte'
      'audience.adult'
    when 'Senior'
      'audience.senior'
    else
      nil
    end
  end

  def course_and_price_hash_from_row(row)
    {
      structure_name:                                 row[0],
      course_type:                                    course_group_class(row[1]),

      course_group: {
        name:                                         row[2],
        # TODO
        # annual_price_adult:                           row[x],
        # annual_price_child:                           row[x],
        # annual_membership_mandatory:                  row[x],
        # annual_membership_mandatory:                  row[x]
      },
      audiences: {
        audience_1:                                   audience_name(row[7]),
        audience_2:                                   audience_name(row[8]),
        audience_3:                                   audience_name(row[9])
      },

      levels: {
        level_2:                                      level_name(row[12]),
        level_1:                                      level_name(row[13])
      },

      # Course
      course: {
        max_age_for_kid:                              row[14],
        min_age_for_kid:                              row[15],
        is_individual:                               (row[16] == 'X' ? true : false),
        course_info_2:                                row[10],
        course_info_1:                                row[11],
        is_for_handicaped:                           (row[17] == 'X' ? true : false),
        registration_date:                            row[20]
      },

      # Price
      price: {
        is_free:                                     (row[42] == 'X' ? true : false),
        individual_course_price:                      row[43],
        annual_price:                                 row[44],
        two_lesson_per_week_package_price:            row[45],
        semester_price:                               row[46],
        trimester_price:                              row[47],
        month_price:                                  row[48],
        five_lessons_price:                           row[49],
        five_lessons_validity:                        row[50],
        ten_lessons_price:                            row[51],
        ten_lessons_validity:                         row[52],
        twenty_lessons_price:                         row[53],
        twenty_lessons_validity:                      row[54],
        thirty_lessons_price:                         row[55],
        thirty_lessons_validity:                      row[56],
        fourty_lessons_price:                         row[57],
        fourty_lessons_validity:                      row[58],
        fifty_lessons_price:                          row[59],
        fifty_lessons_validity:                       row[60],
        book_tickets_a_nb:                            row[61],
        book_tickets_a_price:                         row[62],
        book_tickets_a_validity:                      row[63],
        book_tickets_b_nb:                            row[64],
        book_tickets_b_price:                         row[65],
        book_tickets_b_validity:                      row[66],
        book_tickets_c_nb:                            row[67],
        book_tickets_c_price:                         row[68],
        book_tickets_c_validity:                      row[69],
        unlimited_access_price:                       row[70],
        unlimited_access_validity:                    row[71],
        excluded_lesson_from_unlimited_access_card:   row[72],
        price_info_1:                                 row[73],
        price_info_2:                                 row[74],
        promotion:                                    row[75],
        student_price:                                row[76],
        young_and_senior_price:                       row[77],
        job_seeker_price:                             row[78],
        low_income_price:                             row[79],
        large_family_price:                           row[80],
        degressive_price_from_two_lesson:             row[81],
        couple_price:                                 row[82],
        has_other_preferential_price:                (row[83] == 'X' ? true : false),
        has_exceptional_offer:                       (row[84] == 'X' ? true : false),
        trial_lesson_price:                           row[85],
        details:                                      row[86],

      },

      # Planning
      planning: {
        week_day:                                     row[3],
        start_time:                                   Time.parse("2000-01-01 #{row[4]} UTC"),
        end_time:                                     Time.parse("2000-01-01 #{row[5]} UTC"),
        duration:                                     row[6],
        recurrence:                                   row[18],
        class_during_holidays:                       (row[19] == 'X' ? false : true),

        start_date:                                  (row[21].nil? ? nil : Date.parse(row[21])),
        end_date:                                    (row[22].nil? ? nil : Date.parse(row[22])),

        # For Trainings
        day_one:                                      row[23],
        day_one_start_time:                           row[24],
        day_one_duration:                             row[25],
        day_two:                                      row[26],
        day_two_start_time:                           row[27],
        day_two_duration:                             row[28],
        day_three:                                    row[29],
        day_three_start_time:                         row[30],
        day_three_duration:                           row[31],
        day_four:                                     row[32],
        day_four_start_time:                          row[33],
        day_four_duration:                            row[34],
        day_five:                                     row[35],
        day_five_start_time:                          row[36],
        day_five_duration:                            row[37]
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
      #################################################################### First, finding the structure to associate with
      structure = Structure.where{name == row[:structure_name]}.first
      next if structure.blank?

      # Search if the given structure already have a course group with this course name
      # course_group = structure.course_groups.where(name: row[:course_group][:name]).first

      # CourseGroup.joins{audiences.outer}.joins{levels.outer}.where{(structure_id == structure.id) & (audiences.id == ado.id)}.first
      course_group = CourseGroup.joins{audiences.outer}.joins{levels.outer}.where do
        (name == row[:course_group][:name])
      end.where do
        (structure_id == structure.id)
      end.where do
        row[:audiences].values.compact.map { |audience_name| (audiences.name == audience_name) }.reduce(&:&)
      end.where do
        row[:levels].values.compact.map { |level_name| (levels.name == level_name) }.reduce(&:&)
      end.first

      if course_group.nil?
        # Create course group
        course_group = row[:course_type].create(row[:course_group])

        #################################################################### Associating audiences
        row[:audiences].values.compact.each do |audience_name|
          audience = Audience.where{name == audience_name}.first
          course_group.audiences << audience
        end

        #################################################################### Associating levels
        row[:levels].values.compact.each do |level_name|
          level = Level.where{name == level_name}.first
          course_group.levels << level
        end
        course_group.structure = structure
      end


      course = Course.create(row[:course])
      #################################################################### Creating Planning
      planning = Planning.create(row[:planning])
      course.planning = planning
      #################################################################### Creating Price
      price = Price.create(row[:price])
      course.price = price
      course.save
    end
  end
end
