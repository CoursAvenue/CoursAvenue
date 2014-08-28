class Users::ConversationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_user!
  load_and_authorize_resource :user, find_by: :slug

  layout 'user_profile'

  def show
    @user         = User.find(params[:user_id])
    @conversation = @user.mailbox.conversations.find(params[:id])
    @message      = @conversation.messages.build
    respond_to do |format|
      format.html
    end
  end

  def index
    @conversations = @user.mailbox.conversations
  end

  def new
    @conversation = @user.mailbox.conversations.build
    @message      = @conversation.messages.build
  end

  def update
    @user         = User.find(params[:user_id])
    @conversation = @user.mailbox.conversations.find params[:id]
    @user.reply_to_conversation(@conversation, params[:conversation][:message][:body]) if params[:conversation][:message][:body].present?
    respond_to do |format|
      if params[:conversation][:message][:body].blank?
        format.html { redirect_to user_conversation_path(@user, @conversation), alert: 'Vous ne pouvez pas envoyer de message vide' }
      else
        format.html { redirect_to user_conversation_path(@user, @conversation), notice: 'Message envoyé' }
      end
    end
  end

end
