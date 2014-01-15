# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'users'

  before_filter :update_sanitized_params, if: :devise_controller?

  def after_sign_in_path_for(user)
    session['user_return_to'] || request.referrer || root_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  unless Rails.configuration.consider_all_requests_local
    rescue_from Exception,                            with: :render_error
    rescue_from ActiveRecord::RecordNotFound,         with: :render_not_found
    rescue_from ActionController::RoutingError,       with: :render_not_found
    rescue_from ActionController::UnknownController,  with: :render_not_found
    rescue_from AbstractController::ActionNotFound,   with: :render_not_found
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

  def render_not_found(exception)
    logger.fatal '------------------------ LOGGER NOT FOUND --------------------------'
    logger.fatal exception.message
    exception.backtrace.each { |line| logger.fatal line }
    logger.fatal '------------------------ LOGGER NOT FOUND --------------------------'
    redirect_to root_path, status: 301, notice: "Cette page n'existe plus."
    # render template: 'errors/not_found', status: :not_found
  end

  def render_error(exception)
    logger.fatal '------------------------ LOGGER FATAL --------------------------'
    logger.fatal exception.message
    exception.backtrace.each { |line| logger.fatal line }
    logger.fatal '------------------------ LOGGER FATAL --------------------------'
    render template: 'errors/internal_server_error', status: :not_found
  end

  private

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:email, :first_name, :last_name, :zip_code, :password)}
  end
end
