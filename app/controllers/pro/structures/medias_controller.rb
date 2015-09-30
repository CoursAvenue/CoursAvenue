# encoding: utf-8
class Pro::Structures::MediasController < Pro::ProController
  # Because edit lets you choose if the media will be on the vertical page
  before_action :authenticate_pro_super_admin!, only: [:edit]
  before_action :load_structure

  def index
    @media     = @structure.medias.build
    @image     = Media::Image.new mediable: @structure
    @medias    = @structure.medias.cover_first.videos_first.reject(&:new_record?)
  end

  def destroy
    @media     = Media.find params[:id]
    @media.destroy
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure),
                      notice: 'Photo / vidéo bien supprimé.' }
    end
  end

  def edit
    @media     = Media.find params[:id]
    render layout: false
  end

  def update
    @media     = Media.find params[:id]
    @media.update_attributes(params[:media])
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure),
                      notice: 'Photo / vidéo bien starré.' }
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

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
