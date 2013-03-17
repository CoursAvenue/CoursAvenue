class CitiesController < ApplicationController
  def index
    term = "#{params[:term]}%"
    @cities = City.where{(zip_code =~ term) | (name =~ term)}.limit(20)

    respond_to do |format|
      format.json { render json: @cities }
    end
  end
end
