# encoding: utf-8
class Pro::Structures::WebsiteParametersController < Pro::ProController

  before_action :authenticate_pro_admin!

  load_and_authorize_resource :structure, find_by: :slug

  before_action :get_or_create_parameter

  def index
  end

  def edit
    @website_parameter = @website_parameter.decorate
  end

  def update
    @website_parameter.update_attributes website_parameter_params
    redirect_to edit_pro_reservation_parameter_path(@structure, @website_parameter),
                notice: 'Vos paramètres ont bien été pris en compte'
  end

  private

  def website_parameter_params
    params.require(:website_parameter).permit(:title, :presentation_text)
  end

  def get_or_create_parameter
    @website_parameter = @structure.website_parameter
    @website_parameter ||= WebsiteParameter.create_for_structure(@structure)
  end
end
