# encoding: utf-8
class Structures::CommentsController < ApplicationController
  helper :comments

  layout 'empty'

  def index
    @structure    = Structure.friendly.find(params[:structure_id])
    @comments     = @structure.comments.to_a

    respond_to do |format|
      format.json { render json: @comments }
    end
  end

  def new
    @structure   = Structure.friendly.find(params[:structure_id])
    @comment     = @structure.comments.build
    @comments    = @structure.comments.accepted.reject(&:new_record?)[0..5]
  end

  def show
    @structure    = Structure.friendly.find(params[:structure_id])
    @comment      = Comment.find params[:id]
    if @structure.image.present?
      @logo_url  = @structure.image.url
    end
  end
end
