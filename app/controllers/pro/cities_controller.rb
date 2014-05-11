# encoding: utf-8
class Pro::CitiesController < Pro::ProController
  before_action :authenticate_pro_super_admin!, except: [:zip_code_search]
  layout 'admin'

  def zip_code_search
    term = params[:term]
    @cities = City.where( City.arel_table[:zip_code].matches(term) ).limit(20)

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
      format.html { redirect_to pro_cities_path }
    end
  end
end
