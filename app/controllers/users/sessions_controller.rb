class Users::SessionsController < Devise::SessionsController

  def after_sign_in_path_for(user)
    # Prevent from infininte loop
    banned_url = [new_user_registration_url, new_user_session_url, new_user_password_url]
    session['user_return_to'] = nil if banned_url.include? session['user_return_to']
    referrer = ((request.referrer == new_user_registration_url || request.referrer == new_user_session_url) ? nil : request.referrer)
    session['user_return_to'] || referrer || root_path
  end

  def after_sign_out_path_for(user)
    request.referrer || root_path
  end

  def new
    session['user_return_to'] = request.referrer
    @is_xhr = request.xhr?
    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
