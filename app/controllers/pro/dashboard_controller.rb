# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  before_filter :authenticate_pro_admin!
  def index
    raise CanCan::AccessDenied.new unless current_pro_admin.super_admin?
  end
end
