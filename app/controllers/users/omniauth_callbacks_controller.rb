class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def passthru
    # render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    # Or alternatively,
    raise ActionController::RoutingError.new('Not Found')
  end

  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    # @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', :kind => 'Facebook'
      # redirect_to root_path, :event => :authentication, :current_user => @user
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end
