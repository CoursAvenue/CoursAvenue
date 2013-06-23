# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_filter :authenticate_pro_admin!
  def index
    raise CanCan::AccessDenied.new unless current_pro_admin.super_admin?
    # @admins = Admin.count(:order => 'DATE(created_at) DESC', :group => ["DATE(created_at)"])
    @admins   = Admin  .count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @comments = Comment.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @students = Student.count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
    @users    = User   .count(:order => "DATE_TRUNC('week', created_at) ASC", :group => ["DATE_TRUNC('week', created_at)"])
  end
end

