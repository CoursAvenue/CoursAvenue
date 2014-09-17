# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  def index
    @courses  = Course.where( Course.arel_table[:created_at].gt(Date.parse('01/06/2013')).and(
                               Course.arel_table[:active].eq(true)) ).order("DATE_TRUNC('week', created_at) ASC").group("DATE_TRUNC('week', created_at)").count
    @admins   = Admin  .where( Admin.arel_table[:created_at].gt(Date.today - 1.months) ).order('DATE(created_at) ASC').group('DATE(admins.created_at)').count
    @comments = Comment::Review.where( Comment::Review.arel_table[:created_at].gt(Date.today - 1.months) ).order('DATE(created_at) ASC').group('DATE(comments.created_at)').count

    if params[:with_subjects].present?
      _structures = Structure.joins(:admins).joins(:subjects).group('subjects.id').count
      @structures = {}
      _structures.each do |key, value|
        subj = Subject.friendly.find(key)
        if subj.grand_parent
          @structures[subj.grand_parent.name] = (@structures[subj.grand_parent.name] || 0) + value
        else
          @structures[subj.name] = value
        end
      end
    end
    dates = (2.month.ago.to_date..Date.today).step
    @admins_progression   = {}
    @comments_progression = {}
    dates.each do |date|
      @admins_progression[date]   = Admin.where( Admin.arel_table[:created_at].lt(date) ).count
      @comments_progression[date] = Comment::Review.where( Comment::Review.arel_table[:created_at].lt(date) ).count
    end
    @admins2 = [0, 0, 0, 0]
    Structure.find_each do |s|
      if s.comments_count == nil or s.comments_count == 0
        @admins2[0] += 1
      elsif s.comments_count > 0 and s.comments_count < 5
        @admins2[1] += 1
      elsif s.comments_count > 4 and s.comments_count <= 10
        @admins2[2] += 1
      else
        @admins2[3] += 1
      end
    end

    # Compute all the days to have all the days shown in the graph even when values are empty
    hash_of_days = {}
    ((1.months).ago.to_date..Date.today).each { |date| hash_of_days[date.strftime('%Y-%m-%d')] = 0 }
    @comments_hash = {}
    @comments.each { |date, count| @comments_hash[date.to_s] = count }
    @admins_hash   = {}
    @admins.each { |date, count| @admins_hash[date.to_s] = count }
    @comments_hash  = hash_of_days.merge(@comments_hash) # .reject{|key, value| value == 0}
    @admins_hash    = hash_of_days.merge(@admins_hash)   # .reject{|key, value| value == 0}
    @students   = User.where( User.arel_table[:created_at].gt(Date.today - 2.month) ).order('DATE(created_at) ASC').group('DATE(created_at)').count
    @users      = User.order("DATE_TRUNC('week', created_at) ASC").group("DATE_TRUNC('week', created_at)").count
    @videos     = Media::Video.where( Media::Video.arel_table[:created_at].gt(Date.today - 1.month) ).order('DATE(created_at) ASC').group('DATE(created_at)').count
    @images     = Media::Image.where( Media::Image.arel_table[:created_at].gt(Date.today - 1.month) ).order('DATE(created_at) ASC').group('DATE(created_at)').count
    @medias_dates = (@videos.map(&:first) + @images.map(&:first)).uniq.sort
    @medias_dates.each do |date|
      @videos[date] ||= 0
      @images[date] ||= 0
    end

    @messages = Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].gt(Date.today - 2.months).and(
                                              Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq(Mailboxer::Label::INFORMATION.id)) )
                                       .order('DATE(created_at) ASC').group('DATE(created_at)').count


    @messages_per_months, @actions_phone_per_months, @actions_website_per_months = {}, {}, {}
    (Date.new(2014, 1)..Date.today + 1.month).select {|d| d.day == 1}.map {|d| d - 1}.drop(1).each do |last_day_of_month|
      conv_count = Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].in(((last_day_of_month.beginning_of_month)..last_day_of_month)).and(
                                    Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq(Mailboxer::Label::INFORMATION.id)) ).count
      @messages_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = conv_count
      # Because we didn't have date before then
      if last_day_of_month.month < 9
        stat_count = Metric.generic_interval_count(:actions, ((last_day_of_month.beginning_of_month)..last_day_of_month)) || conv_count

        @actions_phone_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = stat_count - conv_count
        @actions_website_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = 0
      else
        phone_count = Metric.generic_interval_count(:actions, ((last_day_of_month.beginning_of_month)..last_day_of_month), 'telephone') || 0

        @actions_phone_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = phone_count
        website_count = Metric.generic_interval_count(:actions, ((last_day_of_month.beginning_of_month)..last_day_of_month), 'website') || 0

        @actions_website_per_months[I18n.t('date.month_names')[last_day_of_month.month]] = website_count
      end
    end
  end
end

