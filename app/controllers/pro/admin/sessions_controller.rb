class Pro::Admin::SessionsController < Devise::SessionsController
  layout 'admin'
  def after_sign_in_path_for(admin)
    if admin.super_admin?
      structures_path
    else
      if admin.structure
        structure_path(admin.structure)
      else
        new_structure_path
      end
    end
  end
end
