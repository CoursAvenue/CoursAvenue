# encoding: utf-8
class Admin::CommentsController < InheritedResources::Base
  before_action :authenticate_pro_admin!

  load_and_authorize_resource :comment

  layout 'admin'

  def index
    @comments                        = Comment::Review.accepted.order('created_at DESC').limit(40)
    @waiting_for_deletion_comments   = Comment::Review.waiting_for_deletion.order('created_at DESC')
    respond_to do |format|
      format.html
      format.json { render json: @comments }
    end
  end

  def edit
    @comment = Comment::Review.find params[:id]
    unless can? :destroy, @comment
      redirect_to pro_root_path, alert: "Vous n'êtes pas autorisé à voir cette page."
    end
  end

  def update
    @comment = Comment::Review.find params[:id]
    @comment.update_attributes params[:comment_review]
    redirect_to admin_comments_path(anchor: "recommandation-#{@comment.id}")
  end

  def recover
    @comment   = Comment::Review.find params[:id]
    @comment.recover!
    AdminMailer.delay(queue: 'mailers').recommandation_has_been_recovered(@comment.structure, @comment.deletion_reason)
    redirect_to admin_comments_path, notice: "L'avis a été rétabli"
  end

end
