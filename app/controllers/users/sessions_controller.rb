class Users::SessionsController < Devise::SessionsController

  respond_to :html, :json

  def after_sign_in_path_for(user)
    # Prevent from infininte loop
    banned_url = [new_user_registration_url, new_user_session_url, new_user_password_url]
    session['user_return_to'] = nil if banned_url.include? session['user_return_to']
    if banned_url.include? request.referrer
      referrer = nil
    else
      referrer = request.referrer
    end
    session['user_return_to'] || referrer || root_path
  end

  def after_sign_out_path_for(user)
    request.referrer || root_path
  end

  def new
    session['user_return_to'] = request.referrer
    @is_xhr = request.xhr?
    respond_to do |format|
      if request.xhr?
        format.html { render layout: false }
      else
        format.html { redirect_to root_path(anchor: 'connexion') }
      end
    end
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options.merge(recall: 'users/sessions#failure'))
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  def failure
    render :status => 401,
           :json => { is_admin: Admin.where(email: params[:user][:email]).any? }
  end

end
