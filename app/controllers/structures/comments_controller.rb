# encoding: utf-8
class Structures::CommentsController < ApplicationController
  helper :comments

  layout 'empty'

  def new
    @structure   = Structure.find(params[:structure_id])
    @comment     = @structure.comments.build
    @comments    = @structure.comments[0..5].reject(&:new_record?)
  end

  def show
    @structure    = Structure.find(params[:structure_id])
    @comment      = Comment.find params[:id]
    if @structure.image.present?
      @logo_url  = @structure.image.url
    end
  end
end
