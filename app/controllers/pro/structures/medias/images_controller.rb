# encoding: utf-8
class Pro::Structures::Medias::ImagesController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :retrieve_structure
  layout 'admin'

  def index
    @media     = @structure.medias.build
    @medias    = @structure.medias.reject(&:new_record?)
  end

  def create
    params[:media_image][:url].split(',').each do |s3_filepicker_url|
      filepicker_url, s3_path = s3_filepicker_url.split(';')
      url                     = CoursAvenue::Application::S3_BUCKET.objects[s3_path].public_url.to_s
      image                   = Media::Image.new url: url, filepicker_url: filepicker_url, mediable: @structure
      image.image             = URI.parse(url)
      image.save
    end
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Vos images ont bien été ajoutées !' }
      format.js { render nothing: true }
    end
  end

  def new
    @image = Media::Image.new mediable: @structure
  end

  def edit
    @image = @structure.medias.find params[:id]
  end

  def make_it_cover
    @image                  = @structure.medias.find params[:id]
    @structure_cover_images = @structure.medias.images.cover
    @structure_cover_images.map { |image| image.cover = false; image.save }
    @image.cover = true
    @image.save
    respond_to do |format|
      format.html { redirect_to pro_structure_medias_path(@structure), notice: 'Votre image est maintenant visible par défaut sur votre page profil' }
    end
  end

  private

  def retrieve_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
