# encoding: utf-8
class Admin::CitiesController < Admin::AdminController
  include CitySearch

  before_action :authenticate_pro_super_admin!, except: [:zip_code_search]

  def zip_code_search
    @cities = cities_from_zip_code params[:term]

    respond_to do |format|
      format.json { render json: @cities }
    end
  end

  def edit
    @city = City.friendly.find(params[:id])
  end

  def update
    @city = City.friendly.find(params[:id])
    @city.update_attributes params[:city]
    respond_to do |format|
      format.html { redirect_to admin_cities_path }
    end
  end
end
