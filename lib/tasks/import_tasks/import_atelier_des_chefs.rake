# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
# require 'debugger'

# s = Structure.find 'l-atelier-des-chefs'; s.courses.each {|c| c.plannings.delete_all; c.prices.delete_all; c.delete}
namespace :import do

  def adc_to_hash(row)
    hash = {
      place_name:         row[0].gsub('Paris ', ''),
      class_name:         row[1],
      start_date:         Date.strptime(row[2], '%m/%d/%y'),
      start_time:         Time.parse("2000-01-01 #{row[3]} UTC"),
      duration:           row[4],
      info:               row[5],
      nb_place_available: row[6],
      total_nb_place:     row[7],
      price:              row[8],
      promo_price:        row[9]
    }
  end

  # Use rake "import:atelier_des_chefs[Path to CSV]"
  desc 'Import Atelier des chefs courses CSV'
  task :atelier_des_chefs, [:filename] => :environment do |t, args|
    file_name = args.filename || 'Export/atelier_des_chefs.csv'
    puts "Importing: #{file_name}"
    csv_text = File.read(file_name)
    csv = CSV.parse(csv_text)

    csv.each_with_index do |_row, i|
      next if i == 0 # Skipping headers
      puts "Importing #{_row[1]}"
      row = nil
      begin
        row = adc_to_hash(_row)
      rescue
        puts "Blank line: #{row}"
        next
      end
      place = Place.where{name == row[:place_name]}.first
      if place.nil?
        puts "Create #{row[:place_name]}"
        next
      end
      course = place.courses.joins{prices}.where{(name == row[:class_name]) & (prices.amount == row[:price].to_i)}.first
      if course.nil? or !course_price_are_same(course, row)
        course = Course.new(name: row[:class_name],
                            type: 'Course::Workshop',
                            audience_ids: [Audience.adult.id],
                            level_ids: [Level.all_levels.id],
                            subject_ids: [Subject.find('cuisine').id],
                            place_id: place.id,
                            active: true)
        course.save!
      end

      if (planning = course.plannings.where{(start_date == row[:start_date]) & (start_time == row[:start_time])}.first).nil?
        course.plannings.create(start_date: row[:start_date], start_time: row[:start_time], duration: row[:duration])
      else
        planning.update_attribute(:nb_place_available, row[:nb_place_available])
      end
      price = course.prices.where{libelle == 'prices.individual_course'}.first || course.prices.build
      price.update_attributes(libelle: 'prices.individual_course', amount: row[:price] , promo_amount: (row[:promo_price] != '0' ? row[:promo_price] : nil))
      price.save
    end
  end

  # A course can have the same name but different prices
  def course_price_are_same course, row
    price = course.prices.first
    return false if price.nil?
    if price.amount == row[:price] and price.promo_amount == (row[:promo_price] != '0' ? row[:promo_price].to_i : nil)
      return true
    end
    return false
  end
end
