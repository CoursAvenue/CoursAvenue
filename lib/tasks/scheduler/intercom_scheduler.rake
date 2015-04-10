# encoding: utf-8
require 'rake/clean'

namespace :scheduler do
  namespace :intercom do

    # Send email if account expires in 5 days
    # $ rake scheduler:intercom:update_intercom_status
    desc 'Updates Intercom status of admins'
    task :update_intercom_status => :environment do |t, args|
      Admin.find_each do |admin|
        next if admin.structure.nil?
        admin.structure.update_intercom_status
      end
    end
  end
end
