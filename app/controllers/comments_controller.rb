# encoding: utf-8
class CommentsController < ApplicationController
  include CommentsHelper

  def create
    @commentable  = find_commentable
    @comment      = @commentable.comments.build params[:comment]

    # If current user exists, affect it to the comment
    if current_user
      @comment.author_name = current_user.name
      @comment.email       = current_user.email
    else
      user_email = params[:comment][:email]
      # If the user does not exists
      unless (@user = User.where{email == user_email}.first)
        @user = User.new email: params[:comment][:email], first_name: params[:comment][:author_name]
      end
      @user.update_attribute(:first_name, params[:comment][:author_name]) if params[:comment][:author_name].present?
    end
    @comment.user = @user || current_user
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
        format.html { render 'structures/comments/new' }
      end
    end
  end

  private

  def send_private_message
    @recipient    = @comment.structure.main_contact
    @receipt      = @comment.user.send_message(@recipient, params[:private_message], (params[:subject].present? ? params[:subject] : 'Message personnel suite à ma recommandation'))
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
