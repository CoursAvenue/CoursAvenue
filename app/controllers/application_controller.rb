# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  caches_page :robots

  layout 'users'

  helper_method :mobile_device?, :layout_locals, :on_pro_subdomain?,
    :prerender_agent?

  before_filter :update_sanitized_params, if: :devise_controller?

  def after_sign_in_path_for(user)
    session['user_return_to'] || request.referrer || root_path
  end

  unless Rails.configuration.consider_all_requests_local
    rescue_from Exception,                            with: :render_error
    rescue_from Timeout::Error,                       with: :render_timeout
    rescue_from CanCan::AccessDenied,                 with: :not_allowed
    rescue_from ActiveRecord::RecordNotFound,         with: :render_not_found
    rescue_from ActionController::RoutingError,       with: :render_not_found
    rescue_from ActionController::UnknownController,  with: :render_not_found
    rescue_from AbstractController::ActionNotFound,   with: :render_not_found
    rescue_from ActionView::MissingTemplate,          with: :render_not_found
  end

  def authenticate_user!(opts={})
    if current_pro_admin and current_pro_admin.super_admin
      opts[:scope] = :pro_admin
      warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
    else
      opts[:scope] = :user
      warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
    end
  end

  def current_ability
    if current_pro_admin
      @current_ability ||= AdminAbility.new(current_pro_admin)
    elsif current_user
      @current_ability ||= UserAbility.new(current_user)
    else
      @current_ability ||= UserAbility.new(nil)
    end
  end

  # Redirect user to sign_in path if there is a CanCan AccessDenied exception
  # @param  exception
  def not_allowed(exception)
    Bugsnag.notify(exception, {
      custom: { location: 'ApplicationController#now_allowed' }
    })
    if request.subdomain == 'pro'
      redirect_to new_pro_admin_session_url(subdomain: 'pro'), alert: I18n.t('devise.failure.unauthenticated')
    else
      redirect_to root_url(subdomain: 'www'), alert: I18n.t('devise.failure.unauthenticated')
    end
  end

  # TODO: Does this actually work?
  # Redirect users if there a timeout happens
  # @param  exception
  def render_timeout(exception)
    Bugsnag.notify(exception)
    redirect_to request.referer || root_path, status: 301, notice: "La requête a mis trop de temps, veuillez réessayer."
  end

  # Redirect users if there is a not found resource
  # @param  exception
  def render_not_found(exception)
    if params[:id] and ((s = Structure.only_deleted.where(id: params[:id]).first) or
        (s = Structure.only_deleted.where(slug: params[:id])).first)
      redirect_to structures_path_for_city_and_subject(s.city, s.dominant_root_subject), status: 301, notice: "Cette page n'existe plus."
    else
      Bugsnag.notify(exception)
      redirect_to root_path, status: 301, notice: "Cette page n'existe plus."
    end
  end

  # Render the bubble error if there is an error
  # @param  exception
  def render_error(exception)
    Bugsnag.notify(exception)
    render template: 'errors/internal_server_error', status: :not_found
  end

  # Create a RoutingError exception when the route is not matched.
  #
  # @return ActionController::RoutingError
  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  # Check wether the devise is mobile or not
  #
  # @return [type] [description]
  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      if request.user_agent =~ /Mobile|webOS/
        session[:mobile_param] = "1"
        return true
      else
        return false
      end
    end
  end

  def authenticate_pro_super_admin!
    unless current_pro_admin && current_pro_admin.super_admin?
      redirect_to root_path, alert: "Vous n'avez pas le droit !"
    end
  end

  def on_pro_subdomain?
    request.subdomain == 'pro'
  end

  def robots
    robots = File.read(Rails.root + "config/robots/robots.#{Rails.env}.txt")
    render text: robots, layout: false, content_type: "text/plain"
  end

  def mixpanel_tracker
    @tracker ||= MixpanelClientFactory.client
  end

  def prerender_agent?
    return false if request.env.keys.include?('HTTP_USER_AGENT')
    @is_prerender ||= request.env["HTTP_USER_AGENT"].include?('Prerender')
  end

  protected

  def layout_locals
    {}
  end

  private

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :first_name, :last_name, :zip_code, :password, :phone_number) }
  end
end
