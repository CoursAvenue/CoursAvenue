# encoding: utf-8
class Structures::CommentsController < ApplicationController
  helper :comments

  layout 'empty'

  def index
    @structure    = Structure.friendly.find(params[:structure_id])
    @comments     = @structure.comments.accepted.limit(5).to_a

    respond_to do |format|
      format.json { render json: @comments, each_serializer: CommentSerializer }
    end
  end

  def new
    @structure   = Structure.friendly.find(params[:structure_id])
    @comment     = @structure.comments.build
    @comments    = @structure.comments.accepted.reject(&:new_record?)[0..3]
  end

  def show
    @structure    = Structure.friendly.find(params[:structure_id])
    @comment      = @structure.comments.find(params[:id])
    @user         = @comment.user
    @structure_search = StructureSearch.search({ lat: @structure.latitude,
                                                 lng: @structure.longitude,
                                                 radius: 7,
                                                 per_page: 100,
                                                 bbox: true }).results

    @structure_locations = Gmaps4rails.build_markers(@structure_search.select { |s| s.latitude.present? }) do |structure, marker|
      marker.lat structure.latitude
      marker.lng structure.longitude
    end

    respond_to do |format|
      format.json { render json: @comment }
      format.html {}
    end
  end
end
