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
    if params[:id].include?(',')
      params[:id] = params[:id].split(',')
    end

    @comment      = Comment.find(params[:id])

    respond_to do |format|
      format.json { render json: @comment }
      format.html { }
    end
  end
end
