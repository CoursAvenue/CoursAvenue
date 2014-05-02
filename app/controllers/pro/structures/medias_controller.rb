# encoding: utf-8
class Pro::Structures::MediasController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :authenticate_pro_super_admin!, only: [:edit]
  layout 'admin'

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @media     = @structure.medias.build
    @image     = Media::Image.new mediable: @structure
    @medias    = @structure.medias.videos_first.cover_first.reject(&:new_record?)
  end

  def destroy
    @structure = Structure.friendly.find params[:structure_id]
    @media     = Media.find params[:id]
    @media.destroy
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Photo / vidéo bien supprimé.' }
    end
  end

  def edit
    @structure = Structure.friendly.find params[:structure_id]
    @media     = Media.find params[:id]
    render layout: false
  end

  def update
    @structure = Structure.friendly.find params[:structure_id]
    @media     = Media.find params[:id]
    @media.update_attributes(params[:media])
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Photo / vidéo bien starré.' }
      format.js   { render nothing: true }
    end
  end

  def make_it_cover
    @image                  = @structure.medias.find params[:id]
    @structure_cover_images = @structure.medias.cover
    @structure_cover_images.map { |image| image.cover = false; image.save }
    @image.cover = true
    @image.save
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure) }
    end
  end
end
