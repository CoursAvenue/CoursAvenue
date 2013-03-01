class Pro::Admin::AdminUsersController < Admin::AdminsController
  def index
    @admin_users = AdminUser.all
  end
end
