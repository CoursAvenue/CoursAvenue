# encoding: utf-8
class Admin::InvitedUsersController < Admin::AdminController
  def index
    @invited_users = InvitedUser.order('created_at DESC')
    @invited_users = Kaminari.paginate_array(@invited_users).page(params[:page] || 1).per(20)
  end
end
