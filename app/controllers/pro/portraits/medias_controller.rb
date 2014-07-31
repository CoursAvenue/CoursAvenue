# encoding: utf-8
class Pro::Portraits::MediasController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :retrieve_portrait
  layout 'admin'

  def index
    @media     = @portrait.medias.build
    @medias    = @portrait.medias.reject(&:new_record?)
  end

  def create
    params[:media_image][:url].split(',').each do |s3_filepicker_url|
      filepicker_url, s3_path = s3_filepicker_url.split(';')
      url                     = CoursAvenue::Application::S3_BUCKET.objects[s3_path].public_url.to_s
      Media::Image.create url: url, filepicker_url: filepicker_url, mediable: @portrait
    end
    respond_to do |format|
      format.html { redirect_to pro_portraits_path(@portrait), notice: 'Vos images ont bien été ajoutées !' }
      format.js { render nothing: true }
    end
  end

  def update
    @image = @portrait.medias.find params[:id]
    @image.update_attributes params[:media]
    respond_to do |format|
      format.js { render nothing: true }
    end
  end

  def destroy
    @image = @portrait.medias.find params[:id]
    @image.destroy
    respond_to do |format|
      format.html { redirect_to edit_pro_portrait_path(@image.mediable) }
      format.js { render nothing: true }
    end
  end

  def new
    @image = Media::Image.new mediable: @portrait
  end

  private

  def retrieve_portrait
    @portrait = Portrait.friendly.find params[:portrait_id]
  end
end
