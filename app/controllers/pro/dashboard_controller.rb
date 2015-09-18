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

    @messages_per_weeks = {}
    @telephone_per_weeks = {}
    @website_per_weeks = {}
    @teachers_per_weeks = {}
    weeks = []
    16.times do |i|
      weeks << Date.today - (i * 7).days
    end

    @client = ::Analytic::Client.new
    weeks.reverse.each do |beginning_of_week|
      raw_data = @client.total_hits(beginning_of_week.beginning_of_week, beginning_of_week.end_of_week)

      if (beginning_of_week - Date.today).to_i == 0
        convs    = Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].in(((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week)).and(
                                      Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])) )
        conv_count = convs.count
        tel_count     = Rails.cache.fetch("pro/dashboard/tel_count#{Date.today.to_s}") { raw_data.inject(0) { |sum, data| sum + data.metric3.to_i } }
        website_count = Rails.cache.fetch("pro/dashboard/website_count#{Date.today.to_s}") { raw_data.inject(0) { |sum, data| sum + data.metric4.to_i } }
        if params[:ratio]
          structure_ids = raw_data.map(&:dimension1).uniq.reject{|structure_id| begin Structure.with_deleted.find(structure_id).main_contact.nil? rescue nil end}
          teachers_count = (structure_ids && convs.map{ |conv| conv.recipients.select{|r| r.is_a? Admin}.map(&:structure_id) }).length
        end
      else
        tel_count      = Rails.cache.fetch("pro/dashboard/tel_count#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}")     { raw_data.inject(0) { |sum, data| sum + data.metric3.to_i } }
        website_count  = Rails.cache.fetch("pro/dashboard/website_count#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}") { raw_data.inject(0) { |sum, data| sum + data.metric4.to_i } }
        convs = Rails.cache.fetch "pro/dashboard/conv_count/#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}/v2" do
          Mailboxer::Conversation.where(Mailboxer::Conversation.arel_table[:created_at].in(((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week)).and(
                                        Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq_any([Mailboxer::Label::INFORMATION.id, Mailboxer::Label::REQUEST.id])) )
        end
        conv_count = convs.count
        if params[:ratio]
          teachers_count = Rails.cache.fetch "pro/dashboard/teachers_count/#{((beginning_of_week.beginning_of_week)..beginning_of_week.end_of_week).to_s}/v2" do
            structure_ids = raw_data.map(&:dimension1).uniq.reject{|structure_id| begin Structure.with_deleted.find(structure_id).main_contact.nil? rescue nil end}
            (structure_ids && convs.map{ |conv| conv.recipients.select{|r| r.is_a? Admin}.map(&:structure_id) }).length
          end
        end
      end

      @messages_per_weeks[I18n.l(beginning_of_week)]  = conv_count
      @telephone_per_weeks[I18n.l(beginning_of_week)] = tel_count
      @website_per_weeks[I18n.l(beginning_of_week)]   = website_count
      @teachers_per_weeks[I18n.l(beginning_of_week)]  = teachers_count
    end
  end

  def stats
    @no_req, @one_req, @two_req, @five_more_req = {}, {}, {}, {}, {}
    date = Date.today.beginning_of_month
    @months = [date]
    4.times do |i|
      @months << date - i.month
    end

    @months.reverse!
    @client = ::Analytic::Client.new
    @months.each do |beginning_of_month|
      raw_data = @client.total_hits(beginning_of_month, beginning_of_month.end_of_month)
      invalidate_cache = rand if beginning_of_month.end_of_month > Date.today
      reqs = Rails.cache.fetch("pro/dashboard/stats/reqs/#{beginning_of_month.to_s}/#{invalidate_cache}") do
        data = ParticipationRequest.where(created_at: (beginning_of_month)..beginning_of_month.end_of_month).group('structure_id').count
        raw_data.group_by{|raw| raw.dimension1 }.each do |structure_id, data|
          data[structure_id.to_i] ||=0
          data[structure_id.to_i] += data.inject(0) { |sum, data| sum + data.metric3.to_i + data.metric4.to_i }
        end
        data
      end
      @one_req[beginning_of_month]       = reqs.select{|a,b| b == 1}.length
      @two_req[beginning_of_month]       = reqs.select{|a,b| b > 1 && b < 5}.length
      @five_more_req[beginning_of_month] = reqs.select{|a,b| b > 5}.length
      admin_count = Admin.where(Admin.arel_table[:created_at].lt(beginning_of_month.end_of_month)).count
      @no_req[beginning_of_month] = admin_count - @one_req[beginning_of_month] - @two_req[beginning_of_month] - @five_more_req[beginning_of_month]
    end
  end

 end
