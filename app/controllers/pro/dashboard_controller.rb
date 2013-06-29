# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_filter :authenticate_pro_admin!
  def index
    raise CanCan::AccessDenied.new unless current_pro_admin.super_admin?
    # @admins = Admin.count(:order => 'DATE(created_at) DESC', :group => ["DATE(created_at)"])
    @courses  = Course.where{(created_at > Date.parse('01/06/2013')) & (active == true)}.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @admins   = Admin  .where{created_at > Date.today - 2.months - 15.days}.count(:order => "DATE(created_at) ASC", :group => ["DATE(created_at)"])
    @comments = Comment.where{created_at > Date.today - 2.months - 15.days}.count(:order => "DATE(created_at) ASC", :group => ["DATE(created_at)"])
    @students = Student.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @users    = User   .count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @medias   = Media  .count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
  end
end

