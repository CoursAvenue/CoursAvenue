class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(user)
    request.referrer || root_path
  end

  def after_sign_out_path_for(user)
    request.referrer || root_path
  end

  def new
    @is_xhr = request.xhr?
    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
