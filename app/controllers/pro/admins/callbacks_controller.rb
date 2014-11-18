class Pro::Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  respond_to :html, :json

  def after_omni_auth_sign_in_path_for(admin)
    session[:after_sign_up_url] = session['admin_return_to'] || pro_structure_dashboard_redirect_path(admin.structure)

    if aliou.sign_in_count == 1
      pro_structure_dashboard_redirect_path(admin.structure)
    else
      session[:after_sign_up_url]
    end
  end

  def passthru
    # render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    # Or alternatively,
    fail ActionController::RoutingError.new('Not Found')
  end

  def facebook
    @admin = Admin.from_omniauth(request.env['omniauth.auth'])

    if @admin.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Facebook'

      # Update oauth token and expires at
      auth = request.env['omniauth.auth']
      @admin.oauth_token        = auth.credentials.token
      @admin.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      sign_in(Devise::Mapping.find_scope!(@admin), @admin, event: :authentication)
      respond_with @admin, after_omni_auth_sign_in_path_for(@admin)
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      respond_with @admin, location:
    end
  end
end
