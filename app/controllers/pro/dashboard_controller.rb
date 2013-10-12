# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_filter :authenticate_pro_admin!
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
        subj = Subject.find(key)
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

    # Compute all the days to have all the days shown in the graph even when values are empty
    hash_of_days = {}
    ((1.months).ago.to_date..Date.today).each{ |date| hash_of_days[date.strftime("%Y-%m-%d")] = 0}
    @comments  = hash_of_days.merge @comments
    @admins    = hash_of_days.merge @admins

    @students = Student.where{created_at > Date.today - 2.month}.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @users    = User   .count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @medias   = Media  .count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
  end
end

