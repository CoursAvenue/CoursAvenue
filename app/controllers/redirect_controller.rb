class RedirectController < ApplicationController

  def place_show
    redirect_to place_path(params[:id]), status: 301
  end

  def place_index
    redirect_to places_path(params_for_search), status: 301
  end

  def subject_place_index
    redirect_to subject_places_path(params[:subject_id], params_for_search), status: 301
  end

  def lieux
    redirect_to places_path(params_for_search), status: 301
  end

  def lieux_show
    redirect_to place_path(params[:id]), status: 301
  end

  def ville
    redirect_to courses_path, status: 301
  end

  private
  def params_for_search
    params.delete(:action)
    params.delete(:controller)
    params
  end
end
