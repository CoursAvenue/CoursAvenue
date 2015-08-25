# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @admins   = Admin.where( Admin.arel_table[:created_at].gt(Date.today - 1.months) ).order('DATE(created_at) ASC').group('DATE(admins.created_at)').count
    @comments = Comment::Review.where( Comment::Review.arel_table[:created_at].gt(Date.today - 1.months) ).order('DATE(created_at) ASC').group('DATE(comments.created_at)').count

    # Compute all the days to have all the days shown in the graph even when values are empty
    hash_of_days = {}
    ((1.months).ago.to_date..Date.today).each { |date| hash_of_days[date.strftime('%Y-%m-%d')] = 0 }
    @admins_cumul_hash, @comments_cumul_hash = {}, {}
    ((3.months).ago.to_date..Date.today).each do |day, index|
      @admins_cumul_hash[day]   = Admin.where( Admin.arel_table[:created_at].lteq(day) ).count
      @comments_cumul_hash[day] = Comment::Review.where( Comment::Review.arel_table[:created_at].lteq(day) ).count
    end
    @comments_hash  = {}
    @comments.each { |date, count| @comments_hash[date.to_s] = count }
    @admins_hash    = {}
    @admins.each { |date, count| @admins_hash[date.to_s] = count }
    @comments_hash  = hash_of_days.merge(@comments_hash) # .reject{|key, value| value == 0}
    @admins_hash    = hash_of_days.merge(@admins_hash)   # .reject{|key, value| value == 0}
    @users          = User.order("DATE_TRUNC('week', sign_up_at) ASC").group("DATE_TRUNC('week', sign_up_at)").count

    @messages_per_months = {}
    @telephone_per_months = {}
    @website_per_months = {}
    weeks = []
    16.times do |i|
      weeks << Date.today - (i * 7).days
    end

    @client = ::Analytic::Client.new
    weeks.reverse.each do |beginning_of_week|
      raw_data = @client.total_hits(beginning_of_week.beginning_of_week, beginning_of_week.end_of_week)

      if (beginning_of_week - Date.today).to_i == 0
        conv_count     = Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].in(((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week)).and(
                                      Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])) ).count
        tel_count = Rails.cache.fetch("pro/dashboard/tel_count#{Date.today.to_s}") { raw_data.inject(0) { |sum, data| sum + data.metric3.to_i } }
        website_count = Rails.cache.fetch("pro/dashboard/website_count#{Date.today.to_s}") { raw_data.inject(0) { |sum, data| sum + data.metric4.to_i } }
      else
        tel_count      = Rails.cache.fetch("pro/dashboard/tel_count#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}")     { raw_data.inject(0) { |sum, data| sum + data.metric3.to_i } }
        website_count  = Rails.cache.fetch("pro/dashboard/website_count#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}") { raw_data.inject(0) { |sum, data| sum + data.metric4.to_i } }
        conv_count = Rails.cache.fetch "pro/dashboard/conv_count/#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}" do
          Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].in(((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week)).and(
                                        Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])) ).count
        end
      end

      @messages_per_months[I18n.l(beginning_of_week)]  = conv_count
      @telephone_per_months[I18n.l(beginning_of_week)] = tel_count
      @website_per_months[I18n.l(beginning_of_week)]   = website_count
    end

    if params[:more].present?
      @students   = User.where( User.arel_table[:sign_up_at].gt(Date.today - 2.month) ).order('DATE(sign_up_at) ASC').group('DATE(sign_up_at)').count
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

  def metrics
    @messages_per_months = {}
    @telephone_per_months = {}
    @website_per_months = {}
    weeks = []
    20.times do |i|
      weeks << Date.today - (i * 7).days
    end
    @client = ::Analytic::Client.new
    weeks.reverse.each do |beginning_of_week|
      raw_data = @client.total_hits(beginning_of_week.beginning_of_week, beginning_of_week.end_of_week)

      if (beginning_of_week - Date.today).to_i == 0
        conv_count = Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].in(((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week)).and(
                                      Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])) ).count
        tel_count  = raw_data.inject(0) { |sum, data| sum + data.metric3.to_i }
        website_count  = raw_data.inject(0) { |sum, data| sum + data.metric4.to_i }
      else
        tel_count      = Rails.cache.fetch("pro/dashboard/tel_count#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}")     { raw_data.inject(0) { |sum, data| sum + data.metric3.to_i } }
        website_count  = Rails.cache.fetch("pro/dashboard/website_count#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}") { raw_data.inject(0) { |sum, data| sum + data.metric4.to_i } }
        conv_count = Rails.cache.fetch "pro/dashboard/conv_count/#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}" do
          Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].in(((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week)).and(
                                        Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])) ).count
        end
      end

      @messages_per_months[I18n.l(beginning_of_week)]  = conv_count
      @telephone_per_months[I18n.l(beginning_of_week)] = tel_count
      @website_per_months[I18n.l(beginning_of_week)]   = website_count
    end
  end
end

