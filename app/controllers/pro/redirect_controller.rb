class Pro::RedirectController < ApplicationController

  def structures_premium
    @admin = Admin.where(email: params[:email]).first
    if @admin
      redirect_to pro_structure_subscription_plans_url(@admin.structure, subdomain: CoursAvenue::Application::PRO_SUBDOMAIN)
    else
      redirect_to new_pro_admin_session_url(subdomain: CoursAvenue::Application::PRO_SUBDOMAIN)
    end
  end
  def structures_jpo_index
    redirect_to pro_structure_course_opens_url(params[:structure_id], subdomain: CoursAvenue::Application::PRO_SUBDOMAIN), status: 301
  end

  def structure_dashboard
    if current_pro_admin
      redirect_to dashboard_pro_structure_path(current_pro_admin.structure)
    else
      session['pro_admin_return_to'] = pro_structure_dashboard_redirect_path
      redirect_to new_session_path(Admin)
    end
  end

  def structure_edit
    if current_pro_admin
      redirect_to edit_pro_structure_path(current_pro_admin.structure)
    else
      session['pro_admin_return_to'] = pro_structure_edit_redirect_path
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
