# encoding: utf-8
class Pro::Structures::MediasController < InheritedResources::Base
  before_action :authenticate_pro_admin!
  layout 'admin'

  def index
    @structure = Structure.find params[:structure_id]
    @media     = @structure.medias.build
    @medias    = @structure.medias.reject(&:new_record?)
  end

  def destroy
    @structure = Structure.find params[:structure_id]
    destroy! do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Photo / vidéo bien supprimé.'}
    end
  end

  def create
    @structure = Structure.find params[:structure_id]
    @media     = @structure.medias.build params[:media]
    respond_to do |format|
      if @media.save
        format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Photo / vidéo bien ajouté !' }
      else
        format.html { redirect_to pro_structure_medias_path(@structure), alert: "Vous n'avez pas renseigné de lien." }
      end
    end
  end

  def new
    @structure = Structure.find params[:structure_id]
    new! do |format|
      if request.xhr?
        format.html {render partial: 'pro/structures/medias/form' }
      else
        format.html { render template: 'pro/structures/medias/index' }
      end
    end
  end

  def edit
    @structure = Structure.find params[:structure_id]
    @media     = @structure.medias.find params[:id]
    new! do |format|
      if request.xhr?
        format.html {render partial: 'pro/structures/medias/form' }
      else
        format.html { render template: 'pro/structures/medias/index' }
      end
    end
  end

  def update
    @structure = Structure.find params[:structure_id]
    @media     = @structure.medias.find params[:id]
    respond_to do |format|
      if @media.update_attributes params[:media]
        format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Photo / vidéo bien ajouté !' }
      else
        format.html { redirect_to pro_structure_medias_path(@structure), alert: "Vous n'avez pas renseigné de lien." }
      end
    end
  end
end
