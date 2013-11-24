# encoding: utf-8
class Pro::Structures::Medias::ImagesController < Pro::ProController
  before_action :authenticate_pro_admin!
  layout 'admin'


  def index
    @structure = Structure.friendly.find params[:structure_id]
    @media     = @structure.medias.build
    @medias    = @structure.medias.reject(&:new_record?)
  end

  def create
    @structure      = Structure.friendly.find params[:structure_id]
    params[:media_image][:url].split(',').each do |url|
      Media::Image.create url: url, mediable: @structure
    end
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Vos images ont bien été ajoutées !' }
    end
  end

  def new
    @structure = Structure.friendly.find params[:structure_id]
    @image     = Media::Image.new structure: @structure
  end

  def edit
    @structure = Structure.friendly.find params[:structure_id]
    @media     = @structure.medias.find params[:id]

  end
end
