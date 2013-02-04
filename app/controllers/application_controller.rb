class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :retrieve_city

  private
  def retrieve_city
    if params[:city]
      city_name = params[:city]
      @city     = City.where{short_name == city_name}.first
    end
  end
end
