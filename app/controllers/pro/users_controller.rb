# encoding: utf-8
class Pro::UsersController < Pro::ProController
  before_filter :authenticate_pro_admin!

  layout 'admin'

  authorize_resource :users

  def index
    @users         = User.order('created_at DESC').all
    @users_signups = User.count(:order => "DATE(created_at) ASC", :group => ["DATE(created_at)"])
    # @users_signups = @users.group_by{|u| I18n.l(u.created_at, format: :date_short)}.map {|k,v| [k, v.length]}.sort
  end

end
