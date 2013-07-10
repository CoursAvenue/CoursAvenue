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

  def invite_friends_for_feedbacks
    @structure      = Structure.find params[:structure_id]
    @comment        = Comment.find params[:id]
    params[:emails] ||= ''
    emails          = params[:emails].split(',').map(&:strip)
    emails.each do |email|
      StudentMailer.delay.ask_friend_for_feedbacks(@structure, email, @comment)
    end
    respond_to do |format|
      format.html { redirect_to place_path(@structure.places.first), notice: "Merci d'avoir partagé à vos amis !" }
    end
  end

end
