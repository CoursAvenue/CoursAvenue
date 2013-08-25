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
      if @comment.save
        cookies[:delete_cookies] = true
        if params[:from] and params[:from] == 'recommendation-page'
          format.html { redirect_to structure_comment_path(@comment.commentable, @comment), notice: "Merci d'avoir laissé votre avis !" }
        else
          format.html { redirect_to (request.referrer || commentable_path(@comment)), notice: "Merci d'avoir laissé votre avis !" }
        end
        UserMailer.delay.after_comment_for_teacher(@comment)
        UserMailer.delay.after_comment(@comment)
      else
        if @commentable.is_a? Structure
          @structure    = @commentable
          @comments     = @structure.all_comments[0..5]
          flash[:alert] = "Le commentaire n'a pas pu être posté. Assurez-vous d'avoir bien rempli tous les champs."
          format.html { render 'structures/comments/new'}
        else
          format.html { redirect_to commentable_path(@comment), alert: "Le commentaire n'a pas pu être posté. Assurez-vous d'avoir bien rempli tous les champs."}
        end
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    path     = commentable_path(@comment)
    respond_to do |format|
      if can?(:destroy, @comment) and @comment.destroy
        format.html { redirect_to request.referrer || path, notice: 'Votre commentaire a bien été supprimé'}
      else
        format.html { redirect_to request.referrer || path, alert: 'Vous ne pouvez pas supprimer ce commentaire'}
      end
    end
  end

  private
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
