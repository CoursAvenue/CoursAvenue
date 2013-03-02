class Pro::AdminUsersController < InheritedResources::Base
  def index
    @admin_users = AdminUser.all
  end

  def update
    update! do |format|
      format.html do
        if current_admin_user.super_admin?
          redirect_to admin_users_path
        else
          redirect_to structure_path current_admin_user.structure
        end
      end
    end
  end
end
