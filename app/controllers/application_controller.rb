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

  # http://stackoverflow.com/questions/5882264/ruby-on-rails-how-to-determine-if-a-request-was-made-by-a-robot-or-search-engin
  def is_bot?
    !request.env["HTTP_USER_AGENT"].match(/\(.*https?:\/\/.*\)/).nil?
  end

  def current_ability
    @current_ability ||= Ability.new(current_pro_admin)
  end

  def render_not_found(exception)
    logger.fatal '------------------------ LOGGER FATAL --------------------------'
    logger.fatal exception.message
    exception.backtrace.each { |line| logger.fatal line }
    logger.fatal '------------------------ LOGGER FATAL --------------------------'
    render :template => 'errors/not_found', :status => :not_found
  end

  def render_error(exception)
    logger.fatal '------------------------ LOGGER FATAL --------------------------'
    logger.fatal exception.message
    exception.backtrace.each { |line| logger.fatal line }
    logger.fatal '------------------------ LOGGER FATAL --------------------------'
    render :template => 'errors/internal_server_error', :status => :not_found
  end
end
