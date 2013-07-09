class Pro::Admins::ConfirmationsController < Devise::ConfirmationsController
  def after_confirmation_path_for(resource_name, admin)
    if admin.structure
      dashboard_pro_structure_path(admin.structure)
    else
      root_path
    end
  end
end
