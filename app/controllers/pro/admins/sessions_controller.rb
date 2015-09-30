class Pro::Admins::SessionsController < Devise::SessionsController

  layout 'admin_pages'

  def after_sign_in_path_for(admin)
    # Prevent from infininte loop
    banned_url                = [new_pro_admin_session_url(subdomain: 'pro'), new_pro_admin_session_url(subdomain: 'pro'), new_pro_admin_password_url(subdomain: 'pro')]
    session['pro_admin_return_to'] = session['pro_admin_return_to'].gsub('__STRUCTURE_ID__', admin.structure.slug) if session['pro_admin_return_to'].present? and admin.structure.present?
    session['pro_admin_return_to'] = nil if banned_url.include? session['pro_admin_return_to']
    referrer                  = nil if banned_url.include? request.referrer
    if session['pro_admin_return_to']
      session['pro_admin_return_to']
    elsif referrer
      referrer
    elsif admin.structure
      dashboard_pro_structure_path(admin.structure)
    elsif admin.super_admin?
      admin_dashboard_path
    else
      root_path
    end
  end

  def after_sign_out_path_for(admin)
    request.referrer || root_path
  end

  def new
    if request.xhr?
      render partial: 'new_popup'
    else
      respond_to do |format|
        format.json { render nothing: true }
        format.html
      end
    end
  end
end
