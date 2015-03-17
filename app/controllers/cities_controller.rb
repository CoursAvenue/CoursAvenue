class CitiesController < ApplicationController
  include CitySearch

  def show
    redirect_to root_url, status: 410
  end

  def zip_code_search
    @cities = cities_from_zip_code params[:term]

    respond_to do |format|
      format.json { render json: @cities }
    end
  end
end
