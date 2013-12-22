# encoding: utf-8
class Pro::CitiesController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def edit
    @city = City.friendly.find(params[:id])
  end

  def update
    @city = City.friendly.find(params[:id])
    @city.update_attributes params[:city]
    respond_to do |format|
      format.html { redirect_to pro_dashboard_path }
    end
  end

end
