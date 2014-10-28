# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  def index
    @admins   = Admin.where( Admin.arel_table[:created_at].gt(Date.today - 1.months) ).order('DATE(created_at) ASC').group('DATE(admins.created_at)').count
    @comments = Comment::Review.where( Comment::Review.arel_table[:created_at].gt(Date.today - 1.months) ).order('DATE(created_at) ASC').group('DATE(comments.created_at)').count

    # Compute all the days to have all the days shown in the graph even when values are empty
    hash_of_days = {}
    ((1.months).ago.to_date..Date.today).each { |date| hash_of_days[date.strftime('%Y-%m-%d')] = 0 }
    @comments_hash  = {}
    @comments.each { |date, count| @comments_hash[date.to_s] = count }
    @admins_hash    = {}
    @admins.each { |date, count| @admins_hash[date.to_s] = count }
    @comments_hash  = hash_of_days.merge(@comments_hash) # .reject{|key, value| value == 0}
    @admins_hash    = hash_of_days.merge(@admins_hash)   # .reject{|key, value| value == 0}
    @users          = User.order("DATE_TRUNC('week', created_at) ASC").group("DATE_TRUNC('week', created_at)").count

    @messages_per_months, @actions_phone_per_months, @actions_website_per_months = {}, {}, {}
    (Date.new(2014, 1)..Date.today + 1.month).select {|d| d.day == 1}.map {|d| d - 1}.drop(1).each do |last_day_of_month|
      conv_count = Rails.cache.fetch "pro/dashboard/conv_count/#{((last_day_of_month.beginning_of_month)..last_day_of_month).to_s}" do
        Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].in(((last_day_of_month.beginning_of_month)..last_day_of_month)).and(
                                      Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])) ).count
      end
      @messages_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = conv_count
      # Because we didn't have data before then
      if last_day_of_month.month < 9
        stat_count = Rails.cache.fetch "pro/dashboard/stat_count/#{((last_day_of_month.beginning_of_month)..last_day_of_month).to_s}" do
          Metric.generic_interval_count(:actions, ((last_day_of_month.beginning_of_month)..last_day_of_month)) || conv_count
        end

        @actions_phone_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = stat_count - conv_count
        @actions_website_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = 0
      else
        phone_count = Rails.cache.fetch "pro/dashboard/phone_count/#{((last_day_of_month.beginning_of_month)..last_day_of_month).to_s}" do
          Metric.generic_interval_count(:actions, ((last_day_of_month.beginning_of_month)..last_day_of_month), 'telephone') || 0
        end

        @actions_phone_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = phone_count
        website_count = Rails.cache.fetch "pro/dashboard/website_count/#{((last_day_of_month.beginning_of_month)..last_day_of_month).to_s}" do
          Metric.generic_interval_count(:actions, ((last_day_of_month.beginning_of_month)..last_day_of_month), 'website') || 0
        end

        @actions_website_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = website_count
      end
    end

    if params[:more].present?
      @students   = User.where( User.arel_table[:created_at].gt(Date.today - 2.month) ).order('DATE(created_at) ASC').group('DATE(created_at)').count
      @videos     = Media::Video.where( Media::Video.arel_table[:created_at].gt(Date.today - 1.month) ).order('DATE(created_at) ASC').group('DATE(created_at)').count
      @images     = Media::Image.where( Media::Image.arel_table[:created_at].gt(Date.today - 1.month) ).order('DATE(created_at) ASC').group('DATE(created_at)').count
      @medias_dates = (@videos.map(&:first) + @images.map(&:first)).uniq.sort
      @medias_dates.each do |date|
        @videos[date] ||= 0
        @images[date] ||= 0
      end
    end
    @messages = Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].gt(Date.today - 2.months).and(
                                              Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])) )
                                       .order('DATE(created_at) ASC').group('DATE(created_at)').count
  end
end

