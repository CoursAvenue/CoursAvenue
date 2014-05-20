# encoding: utf-8
class Pro::Structures::StatisticsController < InheritedResources::Base
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure

  layout 'admin'

  def index
    @structure  = Structure.find params[:structure_id]
    @statistics = @structure.statistics

    empty_hash_of_days = {}
    (15.days.ago.to_date..Date.today).each { |date| empty_hash_of_days[date] = 0 }

    @impressions, @views, @actions, @contacts = empty_hash_of_days.dup, empty_hash_of_days.dup, empty_hash_of_days.dup, empty_hash_of_days.dup
    @impressions_total_count, @views_total_count, @actions_total_count, @contacts_total_count = 0, 0, 0, 0
    # Selecting all stats from 15 days ago
    # Ordering them by creation date
    # Grouping them by creation date (cast into a date)
    # selecting counting by DISTINCT(user_fingerprint) because each stats is counted only onced per user & per day
    @statistics.impressions.where( Statistic.arel_table[:created_at].gt(Date.today - 15.days) )
                           .order('DATE(created_at) ASC')
                           .group('DATE(created_at)')
                           .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                           .each{ |stat| @impressions[stat.created_at] = stat.user_count; @impressions_total_count += stat.user_count }

    @statistics.views      .where( Statistic.arel_table[:created_at].gt(Date.today - 15.days) )
                           .order('DATE(created_at) ASC')
                           .group('DATE(created_at)')
                           .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                           .each{ |stat| @views[stat.created_at] = stat.user_count; @views_total_count += stat.user_count }

    @statistics.actions    .where( Statistic.arel_table[:created_at].gt(Date.today - 15.days) )
                           .order('DATE(created_at) ASC')
                           .group('DATE(created_at)')
                           .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                           .each{ |stat| @actions[stat.created_at] = stat.user_count; @actions_total_count += stat.user_count }

    @statistics.contacts   .where( Statistic.arel_table[:created_at].gt(Date.today - 15.days) )
                           .order('DATE(created_at) ASC')
                           .group('DATE(created_at)')
                           .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                           .each{ |stat| @contacts[stat.created_at] = stat.user_count; @contacts_total_count += stat.user_count }
  end
end
