# encoding: utf-8
class Pro::StatisticsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    empty_hash_of_days = {}
    (15.days.ago.to_date..Date.today).each { |date| empty_hash_of_days[date] = 0 }

    @impressions, @views, @actions = empty_hash_of_days.dup, empty_hash_of_days.dup, empty_hash_of_days.dup
    @impressions_total_count, @views_total_count, @actions_total_count = 0, 0, 0
    # Selecting all stats from 15 days ago
    # Ordering them by creation date
    # Grouping them by creation date (cast into a date)
    # selecting counting by DISTINCT(user_fingerprint) because each stats is counted only onced per user & per day

    Metric.impressions.where(:created_at.gt => (Date.today - 15.days) )
                      .asc(:created_at)
                      .group_by { |metric| metric.created_at.to_date }
                      .map{ |date, metrics| { created_at: date, user_count: metrics.uniq(&:identify).length } }
                      .each{ |stat| @impressions[stat[:created_at]] = stat[:user_count]; @impressions_total_count += stat[:user_count] }


    Metric.views      .where(:created_at.gt => (Date.today - 15.days) )
                      .asc(:created_at)
                      .group_by { |metric| metric.created_at.to_date }
                      .map{ |date, metrics| { created_at: date, user_count: metrics.uniq(&:identify).length } }
                      .each{ |stat| @views[stat[:created_at]] = stat[:user_count]; @views_total_count += stat[:user_count] }

    Metric.actions    .where(:created_at.gt => (Date.today - 15.days) )
                      .asc(:created_at)
                      .group_by { |metric| metric.created_at.to_date }
                      .map{ |date, metrics| { created_at: date, user_count: metrics.uniq(&:identify).length } }
                      .each{ |stat| @actions[stat[:created_at]] = stat[:user_count]; @actions_total_count += stat[:user_count] }

  end
end
