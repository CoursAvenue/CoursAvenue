# encoding: utf-8
class ::Pro::InvitedUsersController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @invited_users = InvitedUser.order('created_at DESC')
  end

end
