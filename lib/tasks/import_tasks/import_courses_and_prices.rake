# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def course_group_class(name)
    case name
    when 'Cours'
      class_name = CourseGroup::Lesson
    when 'Stage'
      class_name = CourseGroup::Training
    else
      class_name = CourseGroup::Lesson
    end
  end
  def level(name)
    case name
    when 'TN'
      Level.all_levels
    when 'Ini'
      Level.initiation
    when 'D'
      Level.beginner
    when 'I'
      Level.intermediate
    when 'M'
      Level.average
    when 'A'
      Level.advanced
    when 'C'
      Level.confirmed
    else
      nil
    end
  end

  def audience(name)
    case name
    when 'Enfant'
      Audience.kid
    when 'Ado'
      Audience.teenage
    when 'Adulte'
      Audience.adult
    when 'Senior'
      Audience.senior
    else
      nil
    end
  end

  def course_and_price_hash_from_row(row)
    {
      structure_name:                                 row[0],
      course_type:                                    course_group_class(row[1]),

      course_group: {
        name:                                         row[2]
      },
      audiences: {
        audience_1:                                   audience(row[7]),
        audience_2:                                   audience(row[8]),
        audience_3:                                   audience(row[9])
      },

      levels: {
        level_1:                                      level(row[13]),
        level_2:                                      level(row[14])
      },

      # Course
      course: {
        teacher_name:                                 row[10],
        max_age_for_kid:                              row[15],
        min_age_for_kid:                              row[16],
        is_individual:                               (row[17] == 'X' ? true : false),
        course_info_1:                                row[11],
        course_info_2:                                row[12],
        is_for_handicaped:                           (row[18] == 'X' ? true : false),
        registration_date:                            row[20],
        annual_membership_mandatory:                  row[38]
      },

      # Price
      price: {
        annual_registration_adult_fee:                row[39],
        annual_registration_child_fee:                row[40],
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
        key_price:                                    row[87]

      },

      # Planning
      planning: {
        week_day:                                     row[3],
        start_time:                                   Time.parse("2000-01-01 #{row[4]} UTC"),
        end_time:                                     Time.parse("2000-01-01 00:00 UTC"),
        duration:                                     row[6],
        recurrence:                                   row[19],
        class_during_holidays:                       (row[20] == 'X' ? false : true),

        start_date:                                  (row[21].blank? ? Date.parse('01/09/2012') : Date.parse(row[21])),
        end_date:                                    (row[22].blank? ? Date.parse('15/07/2013') : Date.parse(row[22])),

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

      if structure.nil?
        puts "Haven't found '#{row[:structure_name]}' - Check CSV file."
        next
      end

      #################################################################### Checking if have to create a new course group
      # CourseGroups are grouped by same name, audiences and levels
      course_groups = CourseGroup.where{ (name == row[:course_group][:name]) & (structure_id == structure.id) & (type == row[:course_type].name)}.all

      # If no audience specified, add trhee basics audiecne
      # Normally never happens
      if row[:audiences].values.compact.empty?
        row[:audiences] = [Audience.kid, Audience.teenage, Audience.adult]
      else
        row[:audiences] = row[:audiences].values.compact
      end
      row[:audiences].each do |audience|
        course_groups = course_groups.reject do |course_group|
          !course_group.audiences.include? audience
        end
      end

      row[:levels] = row[:levels].values.compact
      row[:levels].each do |level|
        course_groups = course_groups.reject do |course_group|
          !course_group.levels.include? level
        end
      end
      if course_groups.empty?
        # Create course group
        course_group           = row[:course_type].create(row[:course_group])
        course_group.audiences = row[:audiences]
        course_group.levels    = row[:levels]
        course_group.structure = structure
      else
        course_group = course_groups.first
      end

      course = Course.create(row[:course])
      #################################################################### Creating Planning
      planning = Planning.create(row[:planning])
      planning.end_time = planning.start_time + planning.duration.hour.hour + planning.duration.min.minutes if planning.duration
      course.planning = planning
      #################################################################### Creating Price
      price = Price.create(row[:price])
      course.price = price
      course.save
      course_group.courses << course
      course_group.save
    end
    puts "#{CourseGroup.count} Groupe de cours importés"
    puts "#{Course.count} Cours importés"
  end
end
