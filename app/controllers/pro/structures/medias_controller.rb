# encoding: utf-8
class Pro::Structures::MediasController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  layout 'admin'

  def index
    @structure = Structure.find params[:structure_id]
    @media     = @structure.medias.build
    @medias    = @structure.medias.reject(&:new_record?)
  end

  def destroy
    @structure = Structure.find params[:structure_id]
    destroy! do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Media bien supprimé.'}
    end
  end

  def create
    @structure = Structure.find params[:structure_id]
    @media     = @structure.medias.build params[:media]
    respond_to do |format|
      if @media.save
        format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Media bien ajouté !' }
      else
        format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Le lien semble corrompu !' }
      end
    end
  end
end
