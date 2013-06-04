# encoding: utf-8
class Structures::CommentsController < ApplicationController
  include CommentsHelper
  layout 'empty'

  def new
    @structure   = Structure.find(params[:structure_id])
    @comment     = @structure.comments.build
    @comments    = @structure.all_comments[0..5].reject{|c| c.new_record?}
  end
end
