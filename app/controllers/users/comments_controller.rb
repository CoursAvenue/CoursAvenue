# encoding: utf-8
class Users::CommentsController < ApplicationController
  layout 'user_profile'

  load_and_authorize_resource :user, find_by: :slug

  def index
    @user     = User.find params[:user_id]
    @comments = @user.comments
  end

  def edit
    @user    = User.find params[:user_id]
    @comment = Comment::Review.find(params[:id])
  end

  def update
    @user    = User.find params[:user_id]
    @comment = Comment::Review.find(params[:id])
    respond_to do |format|
      if @comment.pending?
        @comment.update_attributes params[:comment]
        format.html { redirect_to user_comments_path(current_user), notice: 'Votre commentaire a bien été mis à jour.' }
      else
        format.html { redirect_to user_comments_path(current_user), notice: 'Vous ne pouvez pas modifier votre commentaire.' }
      end
    end
  end
end
