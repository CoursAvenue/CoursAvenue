class Pro::RedirectController < ApplicationController

  def structure_dashboard
    if current_pro_admin
      redirect_to dashboard_pro_structure_path(current_pro_admin.structure)
    else
      redirect_to new_session_path(Admin)
    end
  end

  def structure_edit
    if current_pro_admin
      redirect_to edit_pro_structure_path(current_pro_admin.structure)
    else
      redirect_to new_session_path(Admin)
    end
  end

  def structures_new
    redirect_to inscription_pro_structures_path(params_for_search), status: 301
  end

  private
  def params_for_search
    params.delete(:action)
    params.delete(:controller)
    params
  end
end
