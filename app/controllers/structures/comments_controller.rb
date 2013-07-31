# encoding: utf-8
class Structures::CommentsController < ApplicationController
  helper :comments

  layout 'empty'

  def new
    @structure   = Structure.find(params[:structure_id])
    @comment     = @structure.comments.build
    @comments    = @structure.all_comments[0..5].reject{|c| c.new_record?}
  end

  def show
    @structure    = Structure.find(params[:structure_id])
    @place        = @structure.places.first
    @comment      = Comment.find params[:id]
    # @main_subject = @structure.parent_subjects.first
    if @place.thumb_image.present?
      @logo_url  = @place.thumb_image.url
    elsif @place.image.present?
      @logo_url  = @place.image.url
    elsif @structure.image.present?
      @logo_url  = @structure.image.url
    end
  end
end
