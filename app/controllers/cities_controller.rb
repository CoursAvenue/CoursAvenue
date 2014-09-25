class CitiesController < ApplicationController

  def zip_code_search
    term = params[:term]
    @cities = City.where( City.arel_table[:zip_code].matches(term) ).limit(20)

    respond_to do |format|
      format.json { render json: @cities }
    end
  end

  def show
    redirect_to root_url, status: 410
  end

  def zip_code_search
    term = params[:term]
    @cities = City.where( City.arel_table[:zip_code].matches(term) ).limit(20)

    respond_to do |format|
      format.json { render json: @cities }
    end
  end
end
