class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'users'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  unless Rails.configuration.consider_all_requests_local
    rescue_from Exception,                            :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  def render_not_found
    render :template => 'errors/not_found', :status => :not_found
  end

  def render_error
    render :template => 'errors/internal_server_error', :status => :not_found
  end
end
