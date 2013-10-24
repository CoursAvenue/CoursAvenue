# encoding: utf-8
class CommentsController < ApplicationController
  include CommentsHelper

  def create
    @commentable  = find_commentable
    @comment      = @commentable.comments.build params[:comment]
    # If current user exists, affect it to the comment
    if current_user
      @comment.user        = current_user
      @comment.author_name = current_user.name
      @comment.email       = current_user.email
    # else, check if the user has changed his email
    elsif params[:default_email].present?
      default_email = params[:default_email]
      # If the user does not change his email, just retrieve the user
      if default_email == params[:comment][:email]
        user = User.where{email == default_email}.first
      # If the user changes his email, change the email of the user
      else
        user = User.where{email == default_email}.first
        user.email = params[:comment][:email]
        user.save(validate: false) # Doesn't validate in case the user has no name and therefore will not be valid
      end
      @comment.user = user
    end
    respond_to do |format|
      if @comment.save
        send_private_message unless params[:private_message].blank?
        cookies[:delete_cookies] = true
        if params[:from] and params[:from] == 'recommendation-page'
          format.html { redirect_to structure_comment_path(@comment.commentable, @comment), notice: "Merci d'avoir laissé votre avis !" }
        else
          format.html { redirect_to (request.referrer || commentable_path(@comment)), notice: "Merci d'avoir laissé votre avis !" }
        end
      else
        @structure    = @commentable
        @comments     = @structure.comments.accepted.reject(&:new_record?)[0..5]
        flash[:alert] = "L'avis n'a pas pu être posté. Assurez-vous d'avoir bien rempli tous les champs."
        format.html { render 'structures/comments/new'}
      end
    end
  end

  private

  def send_private_message
    @recipient    = @comment.structure.main_contact
    @receipt      = @comment.user.send_message(@recipient, params[:private_message], 'Recommendation de ton cours')
    @conversation = @receipt.conversation
  end

  def find_commentable
    type = params[:comment][:commentable_type]
    type.classify.constantize.find(params[:comment][:commentable_id])
  end

  def find_commentable_without_type
    params.each do |name, value|
      # Regex correspondant à la forme model_id
      if name =~ /(.+)_id$/
        # $1 correspond au nom du modèle
        return $1.classify.constantize.find(value)
      end
    end
    nil # Retourne nil si rien n'a été trouvé
  end

end
