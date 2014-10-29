class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  respond_to :html, :json

  def after_omni_auth_sign_in_path_for(user)
    session[:after_sign_up_url] = user.after_sign_up_url || session['user_return_to'] || dashboard_user_path(user)
    if user.sign_in_count == 1
      welcome_users_path
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
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    # @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    # If refers to a user (ex: when user is not registered and receive a message from a teacher)
    @user = User.from_omniauth(request.env['omniauth.auth'])
    Bugsnag.notify(RuntimeError.new("Facebook login -- User"), { auth: { user_id: @user.id, user_name: @user.name, user_email: @user.email, 'omniauth.auth' => request.env['omniauth.auth'] } } )

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Facebook'

      # Update oauth token and expires at
      auth = request.env['omniauth.auth']
      @user.oauth_token        = auth.credentials.token
      @user.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      # redirect_to root_path, :event => :authentication, :current_user => @user
      # sign_in_and_redirect @user, event: :authentication
      sign_in(Devise::Mapping.find_scope!(@user), @user, event: :authentication)
      respond_with @user, location: after_omni_auth_sign_in_path_for(@user)
      # redirect_to after_omni_auth_sign_in_path_for(@user)
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      respond_with @user, location: new_user_registration_url
      # redirect_to new_user_registration_url
    end
  end
end
