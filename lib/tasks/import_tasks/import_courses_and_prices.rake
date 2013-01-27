# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def week_day_number(week_day_name)
    return nil           if week_day_name.blank?
    return week_day_name if week_day_name.is_a? Integer
    return I18n.t('date.day_names').index(week_day_name.downcase)
  end

  def course_class(name)
    case name.downcase
    when 'cours'
      Course::Lesson
    when 'stage'
      Course::Training
    when 'cours-atelier'
      Course::Workshop
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
      course_type:                                    course_class(row[1]),

      course: {
        name:                                         row[2],
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
        conditions:                                   row[99],
        partner_rib_info:                             row[101],
        audition_mandatory:                          (row[102] == 'X' ? true : false),
        refund_condition:                             row[103],
        cant_be_joined_during_year:                  (row[41] == 'X' ? true : false),
        price_info_1:                                 row[73],
        price_info_2:                                 row[74],
        price_details:                                row[87]
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

      # Planning
      planning: {
        nb_place_available:                           row[100],
        promotion:                                    row[104],
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
        'price.annual' =>                             row[44],
        'price.two_lesson_per_week_package' =>        row[45],
        'price.semester' =>                           row[46],
        'price.trimester' =>                          row[47],
        'price.month' =>                              row[48],
        #'price.approximate_price_per_course' =>       row[85]
      }
    }

    # IF X => Contact structure
    unless row[85].blank?
      if row[85] == 'X'
        hash[:prices]['price.trial_lesson'] = nil
      else
        hash[:prices]['price.trial_lesson'] = row[85]
      end
    end

    if hash[:course_type] == Course::Training
      hash[:prices]['price.training'] = row[43]
    else
      hash[:prices]['price.individual_course'] = row[43]
    end

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
    # }

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
      # Courses are grouped by same name, audiences and levels
      courses = Course.where{ (name == row[:course][:name]) & (structure_id == structure.id) & (type == row[:course_type].name) & (teacher_name == row[:course][:teacher_name])}.all

      # If no audience specified, add three basics audiecne
      # Normally never happens
      row[:audiences] = row[:audiences].values.compact
      if row[:audiences].empty?
        row[:audiences] = [Audience.kid, Audience.teenage, Audience.adult]
      end

      row[:audiences].each do |audience|
        courses = courses.reject do |course|
          !course.audiences.include? audience
        end
      end

      row[:levels] = row[:levels].values.compact
      row[:levels].each do |level|
        courses = courses.reject do |course|
          !course.levels.include? level
        end
      end

      if courses.empty?
        # Create course group
        course           = row[:course_type].create(row[:course])
        course.audiences = row[:audiences]
        course.levels    = row[:levels]
        course.structure = structure
      else
        course = courses.first
      end

      #################################################################### Creating Planning
      planning = Planning.create(row[:planning])
      planning.end_time = planning.start_time + planning.duration.hour.hour + planning.duration.min.minutes if planning.duration
      course.plannings << planning
      #################################################################### Registration fees
      row[:registration_fees].each do |registration_fee|
        course.registration_fees << RegistrationFee.create(registration_fee)
      end
      #################################################################### Creating Book tickets
      row[:book_tickets].each do |book_ticket|
        course.book_tickets << BookTicket.create(book_ticket) unless course.book_tickets.any?{|b| b.number == book_ticket[:number]}
      end

      #################################################################### Creating Prices
      row[:prices].each do |key, value|
        course.prices << Price.create(libelle: key, amount: value) if value.present? and !course.prices.any?{|p| p.read_attribute == key}
      end
      course.save
    end
    puts "#{Course.count} Cours importés"
  end
end
