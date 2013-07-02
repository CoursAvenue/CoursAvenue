class Pro::Admins::SessionsController < Devise::SessionsController
  layout 'admin'

  def after_sign_in_path_for(admin)
    if admin.super_admin?
      pro_dashboard_path
    else
      if admin.structure
        session['pro_admin_return_to'] || dashboard_pro_structure_path(admin.structure)
      else
        inscription_pro_structures_path
      end
    end
  end
end
