# encoding: utf-8

require 'rake/clean'
# require 'debugger'

namespace :nutshell do

  # $ rake nutshell:create_child_subjects_tags
  desc 'Update all tags'
  task :create_child_subjects_tags => :environment do |t, args|
    nutshell = load_nutshell
    bar = ProgressBar.new Subject.at_depth(2).count
    Subject.at_depth(2).each do |subject|
      bar.increment!
      begin
        tag = {name: subject.name, entityType: 'Contacts'}
        nutshell.new_tag tag
      # Rescue from existing tag
      rescue
      end
    end
  end

  # $ rake nutshell:update_contacts
  desc 'Update all contacts'
  task :update_contacts => :environment do |t, args|
    # bar = ProgressBar.new Admin.count
    Structure.all.each do |structure|
      CrmSync.update(structure)
    end
  end
end
