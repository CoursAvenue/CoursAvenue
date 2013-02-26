class Admin::SessionsController < Devise::SessionsController
  layout 'admin'
  def after_sign_in_path_for(admin)
    if admin.super_admin?
      profs_structures_path
    else
      if admin.structure
        profs_structure_path(admin.structure)
      else
        new_profs_structure_path
      end
    end
  end
end
