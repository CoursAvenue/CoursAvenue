# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def vertical_page_from_row(row)
    return {
        name: row[0].capitalize,
        keywords: row[1..9].reject(&:blank?),
        subjects_depth_0: row[10],
        subjects_depth_1: row[11],
        subjects_depth_2: row[12],
        comments: row[13],
        title: row[14],
        subtitle: row[15],
        content_first: row[16],
        content_second: row[17],
        content_third: row[18],
        content_fourth: row[19]
      }
  end

  # Use rake import:vertical_pages
  desc 'Import vertical_pages'
  task :vertical_pages, [:filename] => :environment do |t, args|
    file_name = args.filename || 'Export/import_dormants.csv'
    bar = ProgressBar.new 575
    # csv_text = File.read(file_name)
    # csv = CSV.parse(csv_text, { col_sep: ";" })
    # csv.each_with_index do |row, i|
    first = true
    # CSV.foreach(file_name, { col_sep: ";" }) do |row|
    url = 'http://coursavenue-public.s3.amazonaws.com/Imports/pages_verticales.csv'
    CSV.foreach(open(url), { col_sep: ";" }) do |row|
      if first
        first = false
        next
      end
      bar.increment!
      attributes = vertical_page_from_row(row)
      next if VerticalPage.where(name: attributes[:name]).any?
      if attributes[:subjects_depth_2].present?
        subject = Subject.where(name: attributes[:subjects_depth_2]).first
      elsif attributes[:subjects_depth_1].present?
        subject = Subject.where(name: attributes[:subjects_depth_1]).first
      else
        subject = Subject.where(name: attributes[:subjects_depth_0]).first
      end
      if subject.nil?
        puts "#{attributes[:subjects_depth_0]} / #{attributes[:subjects_depth_1]} / #{attributes[:subjects_depth_2]}"
        next
      end
      content = ''
      if attributes[:content_first].present? and attributes[:content_first].downcase != 'x'
        content << "<h3>Bon à savoir / Qu'est-ce que c'est ?</h3>"
        content << "<p>#{attributes[:content_first]}</p>"
      end
      if attributes[:content_second].present? and attributes[:content_second].downcase != 'x'
        content << "<h3>Les bienfaits</h3>"
        content << "<p>#{attributes[:content_second]}</p>"
      end
      if attributes[:content_third].present? and attributes[:content_third].downcase != 'x'
        content << "<h3>Matériel à prévoir</h3>"
        content << "<p>#{attributes[:content_third]}</p>"
      end
      if attributes[:content_fourth].present? and attributes[:content_fourth].downcase != 'x'
        content << "<h3>Astuces & anecdotes</h3>"
        content << "<p>#{attributes[:content_fourth]}</p>"
      end
      VerticalPage.create(name: attributes[:name],
                          keywords: attributes[:keywords].join(','),
                          title: attributes[:title],
                          caption: attributes[:subtitle],
                          content: content,
                          subject_id: subject.id,
                          checked: false,
                          comments: attributes[:comments])
    end
  end
end
