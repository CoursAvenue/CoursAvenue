class Users::ConversationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_user!

  layout 'user_profile'

  def show
    @conversation = current_user.mailbox.conversations.find(params[:id])
    @message      = @conversation.messages.build
  end

  def index
    @conversations = current_user.mailbox.conversations
  end

  def new
    @conversation = current_user.mailbox.conversations.build
    @message      = @conversation.messages.build
  end

  def update
    @conversation = current_user.mailbox.conversations.find params[:id]
    current_user.reply_to_conversation(@conversation, params[:conversation][:message][:body])
    respond_to do |format|
      format.html { redirect_to user_conversation_path(current_user, @conversation) }
    end
  end
end
