class Pro::Admins::SessionsController < Devise::SessionsController
  layout 'admin'

  def after_sign_in_path_for(admin)
    if session['pro_admin_return_to']
      session['pro_admin_return_to']
    elsif admin.structure
      dashboard_pro_structure_path(admin.structure)
    else
      inscription_pro_structures_path
    end
  end
end
