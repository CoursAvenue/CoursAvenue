# encoding: utf-8
class Structures::CommentsController < ApplicationController
  include CommentsHelper
  layout 'empty'

  def new
    @structure   = Structure.find(params[:structure_id])
    @comment     = @structure.comments.build
    @comments    = @structure.all_comments[0..5].reject{|c| c.new_record?}
  end

  def create
    @commentable  = find_commentable
    @comment      = @commentable.comments.build params[:comment]
    if current_user
      @comment.user        = current_user
      @comment.author_name = current_user.full_name
      @comment.email       = current_user.email
    end

    respond_to do |format|
      if !cookies["comment_#{params[:commentable_type]}_#{@commentable.id}"] and @comment.save
        cookies["comment_#{params[:commentable_type]}_#{@commentable.id}"] = true unless Rails.env.development?
        if params[:comment][:commentable_type] == 'Structure'
          format.html { redirect_to (request.referrer || commentable_path(@comment)), notice: "Merci d'avoir laissé votre avis !" }
        else
          format.html { redirect_to commentable_path(@comment), notice: "Merci d'avoir laissé votre avis !" }
        end
      elsif cookies["comment_course_#{@commentable.id}"]
        format.html { redirect_to commentable_path(@comment), alert: "Vous ne pouvez pas poster deux commentaires sur le même #{@commentable.class.model_name.human.downcase}."}
      else
        if params[:comment][:commentable_type] == 'Structure'
          format.html { render '/comments/new', alert: "Le commentaire n'a pas pu être posté. Assurez-vous d'avoir bien remplis tous les champs."}
        else
          format.html { redirect_to commentable_path(@comment), alert: "Le commentaire n'a pas pu être posté. Assurez-vous d'avoir bien remplis tous les champs."}
        end
      end
      if @comment.email.present?
        begin
          UserMailer.after_comment(@comment).deliver!
        rescue Exception => exception
          logger.error '------------------------ LOGGER ERROR --------------------------'
          logger.error "Couldn't send email to #{@comment.email}"
          logger.error exception.message
          logger.error '------------------------ LOGGER ERROR --------------------------'
        end
      end
    end
  end
end
