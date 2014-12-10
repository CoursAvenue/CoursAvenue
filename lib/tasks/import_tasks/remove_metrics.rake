# encoding: utf-8

namespace :metric do
  desc 'Delete all the duplicated metrics from the beginning to 15 days ago'
  task :delete => :environment do
    start_date = Metric.first.created_at.to_date
    end_date = 15.days.ago

    (start_date..end_date).each do |date|
      Metric.duplicated(date).each do |metric|
        metric.delay(queue: 'metric').destroy
      end
    end
  end
end

