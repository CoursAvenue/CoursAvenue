class Pro::Structures::Comments::CommentRepliesController < Pro::ProController

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug
  layout 'admin'


  def new
    @comment       = @structure.comments.find params[:comment_id]
    @comment_reply = Comment::Reply.new commentable: @comment
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def create
    @comment       = @structure.comments.find params[:comment_id]
    @comment_reply = Comment::Reply.new params[:comment_reply]
    @comment_reply.commentable = @comment
    @comment_reply.save
    respond_to do |format|
      format.html { redirect_to pro_structure_comments_path(@structure) }
      format.js
    end
  end

end
