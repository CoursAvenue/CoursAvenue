# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def week_day_number(week_day_name)
    return nil           if week_day_name.blank?
    return week_day_name if week_day_name.is_a? Integer

    case week_day_name.downcase
    when 'lundi'
      1
    when 'mardi'
      2
    when 'mercredi'
      3
    when 'jeudi'
      4
    when 'vendredi'
      5
    when 'samedi'
      6
    when 'dimanche'
      7
    else
      week_day_name.to_i
    end
  end

  def course_group_class(name)
    case name.downcase
    when 'cours'
      class_name = CourseGroup::Lesson
    when 'stage'
      class_name = CourseGroup::Training
    when 'cours-atelier'
      class_name = CourseGroup::Workshop
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
    hash = {
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
        min_age_for_kid:                              row[15],
        max_age_for_kid:                              row[16],
        is_individual:                               (row[17] == 'X' ? true : false),
        course_info_1:                                row[11],
        course_info_2:                                row[12],
        is_for_handicaped:                           (row[18] == 'X' ? true : false),
        registration_date:                            row[20],
        annual_membership_mandatory:                  row[38],
        trial_lesson_info:                            row[86],
        has_online_payment:                          (row[94] == 'X' ? true : false),
        formule_1:                                    row[95],
        formule_2:                                    row[96],
        formule_3:                                    row[97],
        formule_4:                                    row[98],
        conditions:                                   row[99],
        nb_place_available:                           row[100],
        partner_rib_info:                             row[101],
        audition_mandatory:                          (row[102] == 'X' ? true : false),
        refund_condition:                             row[103],
        promotion:                                    row[104],
        cant_be_joined_during_year:                  (row[41] == 'X' ? true : false),
        price_info_1:                                 row[73],
        price_info_2:                                 row[74],
        price_details:                                row[87]

      },

      # Planning
      planning: {
        week_day:                                     week_day_number(row[3]),
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
      },
      # Prices
      prices: {
        'price.free' =>                              (row[42] == 'X' ? 0 : nil),
        'price.individual_course' =>                  row[43],
        'price.annual' =>                             row[44],
        'price.two_lesson_per_week_package' =>        row[45],
        'price.semester' =>                           row[46],
        'price.trimester' =>                          row[47],
        'price.month' =>                              row[48],
        'price.student' =>                            row[76],
        'price.young_and_senior' =>                   row[77],
        'price.job_seeker' =>                         row[78],
        'price.low_income' =>                         row[79],
        'price.large_family' =>                       row[80],
        'price.couple' =>                             row[82],
        'price.trial_lesson' =>                       row[85]
        #'price.approximate_price_per_course' =>       row[85]
      }
    }
    # -------------------------------------------------------------------- Registration fees
    hash[:registration_fees] = []
    hash[:registration_fees] << {
      price:    row[39],
      for_kid:  false
    } unless row[39].blank?

    hash[:registration_fees] << {
      price:    row[40],
      for_kid:  true
    } unless row[39].blank?

    # -------------------------------------------------------------------- Book Ticket
    # -------------------------------------------------------------------- Prices
    hash[:book_tickets] = []
    hash[:book_tickets] << {
      number:   5,
      price:    row[49],
      validity: row[50]
    } unless row[49].blank?

    hash[:book_tickets] << {
      number:   10,
      price:    row[51],
      validity: row[52]
    } unless row[51].blank?

    hash[:book_tickets] << {
      number:   20,
      price:    row[53],
      validity: row[54]
    } unless row[53].blank?

    hash[:book_tickets] << {
      number:   30,
      price:    row[55],
      validity: row[56]
    } unless row[55].blank?

    hash[:book_tickets] << {
      number:   40,
      price:    row[57],
      validity: row[58]
    } unless row[57].blank?

    hash[:book_tickets] << {
      number:   50,
      price:    row[59],
      validity: row[60]
    } unless row[59].blank?

    hash[:book_tickets] << {
      number:   row[61],
      price:    row[62],
      validity: row[63]
    } unless row[61].blank?

    hash[:book_tickets] << {
      number:   row[64],
      price:    row[65],
      validity: row[66]
    } unless row[64].blank?

    hash[:book_tickets] << {
      number:   row[67],
      price:    row[68],
      validity: row[69]
    } unless row[67].blank?

    # book_tickets: {
    #   unlimited_access_price:                       row[70],
    #   unlimited_access_validity:                    row[71],
    #   excluded_lesson_from_unlimited_access_card:   row[72],
    #   has_other_preferential_price:                (row[83] == 'X' ? true : false),
    #   degressive_price_from_two_lesson:             row[81],
    #   has_exceptional_offer:                       (row[84] == 'X' ? true : false),
    # }
    ## TODO
    # price_1:                                      row[88].to_i,
    # price_1_libelle:                              row[89],
    # price_2:                                      (row[90].blank? ? nil : row[90].to_i),
    # price_2_libelle:                              row[91],
    # approximate_price_per_course:                 (row[92].blank? ? nil : row[92].to_i)

    hash
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
      #################################################################### Registration fees
      row[:registration_fees].each do |registration_fee|
        course.registration_fees << RegistrationFee.create(registration_fee)
      end
      #################################################################### Creating Book tickets
      row[:book_tickets].each do |book_ticket|
        course.book_tickets << BookTicket.create(book_ticket)
      end

      #################################################################### Creating Prices
      row[:prices].each do |key, value|
        course.prices << Price.create(libelle: key, amount: value) unless value.blank?
      end
      #price = Price.create(row[:price])
      #course.price = price
      course.save
      course_group.courses << course
      course_group.save
    end
    puts "#{CourseGroup.count} Groupe de cours importés"
    puts "#{Course.count} Cours importés"
  end
end
