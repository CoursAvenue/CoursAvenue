# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_action :authenticate_pro_admin!
  def index
    raise CanCan::AccessDenied.new unless current_pro_admin.super_admin?
    # @admins = Admin.count(:order => 'DATE(created_at) DESC', :group => ["DATE(created_at)"])
    @courses  = Course.where{(created_at > Date.parse('01/06/2013')) & (active == true)}.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @admins   = Admin  .where{created_at > Date.today - 1.months}.count(:order => "DATE(created_at) ASC", :group => ["DATE(created_at)"])
    @comments = Comment.where{created_at > Date.today - 1.months}.count(:order => "DATE(created_at) ASC", :group => ["DATE(created_at)"])

    @admins_weekly   = Admin  .where{created_at > Date.today - 3.months}.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @comments_weekly = Comment.where{created_at > Date.today - 3.months}.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])

    if params[:with_subjects].present?
      _structures = Structure.joins{admins}.joins{subjects}.count(:group => ["subjects.id"])
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
      @admins_progression[date]   = Admin.where{created_at < date}.count
      @comments_progression[date] = Comment.where{created_at < date}.count
    end
    @admins2 = [0,0,0,0]
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
    ((1.months).ago.to_date..Date.today).each{ |date| hash_of_days[date.strftime("%Y-%m-%d")] = 0}
    @comments_hash = {}
    @comments.each{|date, count| @comments_hash[date.to_s] = count}
    @admins_hash   = {}
    @admins.each{|date, count| @admins_hash[date.to_s] = count}
    @comments_hash  = hash_of_days.merge(@comments_hash) #.reject{|key, value| value == 0}
    @admins_hash    = hash_of_days.merge(@admins_hash)   #.reject{|key, value| value == 0}
    @students = User.where{created_at > Date.today - 2.month}.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @users    = User   .count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @medias   = Media  .count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
  end
end

