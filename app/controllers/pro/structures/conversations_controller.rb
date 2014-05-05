class Pro::Structures::ConversationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_pro_admin!
  before_action :get_structure, :get_admin

  layout 'admin'

  def show
    @conversation = @admin.mailbox.conversations.find(params[:id])
    @message      = @conversation.messages.build
  end

  def index
    if params[:conversation_label_id].present?
      @conversations = @admin.mailbox.conversations.where(mailboxer_label_id: params[:conversation_label_id])
    else
      @conversations = @admin.mailbox.conversations
    end
    @conversations = Kaminari.paginate_array(@conversations).page(params[:page] || 1).per(15)
  end

  def new
    @conversation = @admin.mailbox.conversations.build
    @message      = @conversation.messages.build
  end

  def update
    @conversation    = @admin.mailbox.conversations.find params[:id]
    @admin.reply_to_conversation(@conversation, params[:conversation][:message][:body])
    respond_to do |format|
      format.html { redirect_to pro_structure_conversation_path(@structure, @conversation) }
    end
  end

  private

  def get_structure
    @structure = Structure.find params[:structure_id]
  end

  def get_admin
    @admin = @structure.main_contact
  end
end
