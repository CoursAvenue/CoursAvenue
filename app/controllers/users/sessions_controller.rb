class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(user)
    request.referrer || root_path
  end

  def new
    respond_to do |format|
      format.html { render layout: false }
    end
  end
end
