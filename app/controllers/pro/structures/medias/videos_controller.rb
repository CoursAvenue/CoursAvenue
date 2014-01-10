# encoding: utf-8
class Pro::Structures::Medias::VideosController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :retrieve_structure
  layout 'admin'

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @media     = @structure.medias.build
    @medias    = @structure.medias.reject(&:new_record?)
  end

  def create
    @structure      = Structure.friendly.find params[:structure_id]
    @media          = Media::Video.new params[:media_video]
    @media.mediable = @structure
    respond_to do |format|
      if @media.save
        format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Photo / vidéo bien ajoutée !' }
      else
        format.html { render :new }
      end
    end
  end

  def new
    @structure = Structure.friendly.find params[:structure_id]
    @video     = Media::Video.new mediable: @structure
  end

  def edit
    @structure = Structure.friendly.find params[:structure_id]
    @media     = @structure.medias.find params[:id]
  end

  def make_it_cover
    @video                  = @structure.medias.find params[:id]
    @structure_cover_video  = @structure.medias.videos.cover
    @structure_cover_video.map{ |video| video.cover = false; video.save }
    @video.cover = true
    @video.save
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Votre vidéo est maintenant visible par défaut sur votre page profil' }
    end
  end

  private

  def retrieve_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
