class Admin::ImagesController < ApplicationController
  before_action :authenticate_pro_super_admin!

  def index
    images = Admin::Image.all.map do |image|
      { thumb: image.small, image: image.url }
    end

    render json: images
  end

  def create
    image = Admin::Image.new
    image.image = params[:file]
    image.save

    render json: { filelink: image.url }
  end
end
