class Pro::Admins::PasswordsController < Devise::PasswordsController
  def after_resetting_password_path_for(admin)
    if admin.structure
      dashboard_pro_structure_path(admin.structure)
    else
      root_path
    end
  end
end
