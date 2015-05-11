class Pro::Structures::RedactorImagesController < ApplicationController
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def index
    images = @structure.medias.images.map do |media|
      { thumb: media.image.redactor.url, image: media.image.url }
    end

    render json: images
  end

  def create
    image = @structure.medias.images.new
    image.remote_image_url = params[:file]
    image.save

    render json: { filelink: image.url }
  end
end
