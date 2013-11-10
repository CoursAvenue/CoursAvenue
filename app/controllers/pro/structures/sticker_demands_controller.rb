# encoding: utf-8
class Pro::Structures::StickerDemandsController < Pro::ProController
  before_action               :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def create
    @structure      = Structure.friendly.find params[:structure_id]

    respond_to do |format|
      format.html { redirect_to params[:redirect_to] || recommendations_pro_structure_path(@structure), notice: (params[:emails].present? ? 'Vos élèves ont bien été notifiés.': nil)}
    end
  end
end
