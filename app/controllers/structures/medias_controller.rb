# encoding: utf-8
class Structures::MediasController < ApplicationController
  layout 'empty'

  def index
    @structure    = Structure.friendly.find(params[:structure_id])
    limit = (@structure.premium? ? 20 : 1)
    @medias       = @structure.medias.videos_first.limit(limit).to_a

    respond_to do |format|
      format.json { render json: @medias, each_serializer: MediaSerializer }
    end
  end
end
