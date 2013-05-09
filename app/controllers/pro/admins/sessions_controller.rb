class Pro::Admins::SessionsController < Devise::SessionsController
  layout 'admin'

  def after_sign_in_path_for(admin)
    if admin.super_admin?
      pro_admins_path
    else
      if admin.structure
        pro_structure_path(admin.structure)
      else
        new_pro_structure_path
      end
    end
  end
end
