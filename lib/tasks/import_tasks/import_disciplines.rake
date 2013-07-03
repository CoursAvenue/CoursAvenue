# encoding: utf-8

# Import all structures from CSV
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do

  def subjects_hash_from_row(row)
    {
      parent_name:          row[0],
      sub_parent_name:      row[1],
      child_name:           row[2],
      child_to_replace:     row[5]
    }
  end
  # Use rake import:subjects
  desc 'Import Subjects rooms from CSV'
  task :subjects, [:filename] => :environment do |t, args|
    file_name = args.filename || 'Export/subjects.csv'

    csv_text = File.read(file_name)
    csv      = CSV.parse(csv_text)
    bar = ProgressBar.new 1084
    csv.each_with_index do |row, i|
      row = subjects_hash_from_row(row)
      bar.increment! 1
      next if row[:parent_name].blank?

      parent_subject     = Subject.find_or_create_by_name row[:parent_name]
      sub_parent_subject = Subject.find_or_create_by_name(row[:sub_parent_name]) ; sub_parent_subject.parent = parent_subject; sub_parent_subject.save
      child_subject      = Subject.find_or_create_by_name(row[:child_name])      ; child_subject.parent      = sub_parent_subject; child_subject.save
      if row[:child_to_replace].present?
        child_to_replace  = Subject.where{name == row[:child_to_replace]}.first
        unless child_to_replace.nil?
          child_to_replace.structures.each do |structure|
            sub_parent_subject.image = child_to_replace.image ; sub_parent_subject.save
            structure.subjects << sub_parent_subject
            structure.save
          end
          child_to_replace.courses.each do |course|
            sub_parent_subject.image = child_to_replace.image ; sub_parent_subject.save
            course.subjects << sub_parent_subject
            course.save
          end
          child_to_replace.destroy
        end
      end
    end
    Subject.where{created_at < Date.yesterday}.all.each do |subject|
      subject.children.delete_all
      subject.delete
    end
  end
end
