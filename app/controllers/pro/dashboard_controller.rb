# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  def index
    @admins_by_hour = { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0, 13 => 0, 14 => 0, 15 => 0, 16 => 0, 17 => 0, 18 => 0, 19 => 0, 20 => 0, 21 => 0, 22 => 0, 23 => 0 }
    Admin.find_each do |admin|
      @admins_by_hour[admin.created_at.hour] += 1
    end

    @comments_by_hour = { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0, 13 => 0, 14 => 0, 15 => 0, 16 => 0, 17 => 0, 18 => 0, 19 => 0, 20 => 0, 21 => 0, 22 => 0, 23 => 0 }
    Comment.find_each do |admin|
      @comments_by_hour[admin.created_at.hour] += 1
    end

    @courses  = Course.where( Course.arel_table[:created_at].gt(Date.parse('01/06/2013')).and(
                               Course.arel_table[:active].eq(true)) ).order("DATE_TRUNC('week', created_at) ASC").group("DATE_TRUNC('week', created_at)").count
    @admins   = Admin  .where( Admin.arel_table[:created_at].gt(Date.today - 1.months) ).order('DATE(created_at) ASC').group('DATE(admins.created_at)').count
    @comments = Comment.where( Comment.arel_table[:created_at].gt(Date.today - 1.months) ).order('DATE(created_at) ASC').group('DATE(comments.created_at)').count

    @admins_weekly   = Admin  .where( Admin.arel_table[:created_at].gt(Date.today - 3.months) ).order("DATE_TRUNC('week', created_at) ASC").group("DATE_TRUNC('week', created_at)").count
    @comments_weekly = Comment.where( Comment.arel_table[:created_at].gt(Date.today - 3.months) ).order("DATE_TRUNC('week', created_at) ASC").group("DATE_TRUNC('week', created_at)").count

    if params[:with_subjects].present?
      _structures = Structure.joins { admins }.joins { subjects }.count(group: ['subjects.id'])
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
      @comments_progression[date] = Comment.where( Comment.arel_table[:created_at].lt(date) ).count
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
    @messages = Mailboxer::Conversation.where( subject: "Demande d'informations" ).order('DATE(created_at) ASC').group('DATE(created_at)').count
  end
end
