class CitiesController < ApplicationController
  def name_search
    term = "#{params[:term]}%"
    @cities = City.where{name =~ term}.order('zip_code ASC').limit(20)

    respond_to do |format|
      format.json { render json: @cities }
    end
  end

  def zip_code_search
    term = params[:term]
    @cities = City.where{zip_code =~ term}.limit(20)

    respond_to do |format|
      format.json { render json: @cities }
    end
  end
end
