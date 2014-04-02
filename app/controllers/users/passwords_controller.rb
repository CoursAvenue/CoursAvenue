class Users::PasswordsController < Devise::PasswordsController
  def after_resetting_password_path_for(user)
    dashboard_user_path(user)
  end
end
