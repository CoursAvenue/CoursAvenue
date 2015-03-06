class Pro::Structures::Comments::CommentRepliesController < Pro::ProController

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug
  before_action :load_comment

  layout 'admin'


  def new
    @comment_reply = Comment::Reply.new commentable: @comment
    @conversation  = @comment.associated_message.conversation
    respond_to do |format|
      format.html { render partial: 'form' }
    end
  end

  def create
    @comment_reply = Comment::Reply.new params[:comment_reply]
    if params[:comment_reply][:show_to_everyone] == '1'
      @comment_reply.commentable = @comment
      @comment_reply.save
    end
    @conversation = @comment.associated_message.conversation
    @structure.main_contact.reply_to_conversation(@conversation, params[:comment_reply][:content]) if params[:comment_reply][:content].present?
    respond_to do |format|
      format.html { redirect_to pro_structure_comments_path(@structure) }
      format.js
    end
  end

  def ask_for_deletion
    @comment_reply = @comment.reply
    render layout: false
  end

  def edit
    @comment_reply = @comment.reply
    @conversation  = @comment.associated_message.conversation
    respond_to do |format|
      format.html { render partial: 'form' }
    end
  end

  def update
    @comment_reply = @comment.reply
    @comment_reply.update_attributes params[:comment_reply]
    respond_to do |format|
      format.html { redirect_to pro_structure_comments_path(@structure) }
      format.js
    end
  end

  def destroy
    @comment_reply = @comment.reply
    @comment_reply.destroy
    respond_to do |format|
      format.html { redirect_to pro_structure_comments_path(@structure) }
      format.js
    end
  end

  private

  def load_comment
    @comment = Comment::Review.find params[:comment_id]
  end

end
