# encoding: utf-8
class Pro::Structures::MediasController < Pro::ProController
  before_action :authenticate_pro_admin!
  layout 'admin'

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @media     = @structure.medias.build
    @medias    = @structure.medias.reject(&:new_record?)
  end

  def destroy
    @structure = Structure.friendly.find params[:structure_id]
    @media     = Media.find params[:id]
    @media.destroy
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Photo / vidéo bien supprimé.'}
    end
  end

end
