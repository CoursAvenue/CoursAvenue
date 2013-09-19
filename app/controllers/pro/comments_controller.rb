# encoding: utf-8
class Pro::CommentsController < InheritedResources::Base
  before_filter :authenticate_pro_admin!
  load_and_authorize_resource :comment

  layout 'admin'

  def index
    @comments                        = Comment.accepted.order('created_at DESC').limit(40)
    @waiting_for_deletion_comments   = Comment.waiting_for_deletion.order('created_at DESC')
    @waiting_for_validation_comments = Comment.pending.order('created_at DESC')
  end

  def edit
    @comment = Comment.find params[:id]
    unless can? :destroy, @comment
      redirect_to pro_root_path, alert: "Vous n'êtes pas autorisé à voir cette page."
    end
  end

  def update
    @comment = Comment.find params[:id]
    @comment.update_attributes params[:comment]
    redirect_to pro_comments_path(anchor: "recommandation-#{@comment.id}")
  end
end
