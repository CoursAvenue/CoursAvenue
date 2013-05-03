# encoding: utf-8
class CommentsController < ApplicationController
  include CommentsHelper

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
        format.html { redirect_to commentable_path(@comment), notice: "Merci d'avoir laissé votre avis !" }
      elsif cookies["comment_course_#{@commentable.id}"]
        format.html { redirect_to commentable_path(@comment), alert: "Vous ne pouvez pas poster deux commentaires sur le même #{@commentable.class.model_name.human.downcase}."}
      else
        format.html { redirect_to commentable_path(@comment), alert: "Le commentaire n'a pas pu être posté. Assurez-vous d'avoir bien remplis tous les champs."}
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

  private
  def find_commentable
    type = params[:comment][:commentable_type]
    type.classify.constantize.find(params[:comment][:commentable_id])
  end
end
