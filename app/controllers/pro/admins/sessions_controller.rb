class Pro::Admins::SessionsController < Devise::SessionsController
  layout 'admin'

  def after_sign_in_path_for(admin)
    session['pro_admin_return_to'] = (session['pro_admin_return_to'] == new_pro_admin_session_url(subdomain: 'pro') ? nil : session['pro_admin_return_to'])
    referrer = ((request.referrer == new_pro_admin_session_url(subdomain: 'pro')) ? nil : request.referrer)
    if session['pro_admin_return_to']
      session['pro_admin_return_to']
    elsif referrer
      referrer
    elsif admin.structure
      dashboard_pro_structure_path(admin.structure)
    elsif admin.super_admin?
      pro_dashboard_path
    else
      root_path
    end
  end

  def after_sign_out_path_for(admin)
    request.referrer || root_path
  end
end
