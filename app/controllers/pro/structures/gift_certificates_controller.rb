class Pro::Structures::GiftCertificatesController < ApplicationController
  before_action :authenticate_pro_admin!, :set_structure
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  def index
    @gift_certificates = @structure.gift_certificates.decorate
  end

  private

  def set_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end

  def gift_certificate_params
    params.require(:gift_certificate).permit(:name, :amount, :description)
  end
end
