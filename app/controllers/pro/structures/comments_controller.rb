# encoding: utf-8
class Pro::Structures::CommentsController < InheritedResources::Base#Pro::ProController
  before_filter :authenticate_pro_admin!
  layout 'admin'

  def index
    @structure = Structure.find params[:structure_id]
    unless can? :read, @structure
      redirect_to pro_root_path, alert: "Vous n'êtes pas autorisé à voir cette page."
    end
    @comments         = @structure.comments.accepted
    @pending_comments = @structure.comments.pending
  end

  def accept
    @structure = Structure.find params[:structure_id]
    @comment   = @structure.comments.find params[:id]
    @comment.accept!
    redirect_to pro_structure_comments_path(@structure)
  end

  def decline
    @structure = Structure.find params[:structure_id]
    @comment   = @structure.comments.find params[:id]
    @comment.decline!
    redirect_to pro_structure_comments_path(@structure)
  end
end
