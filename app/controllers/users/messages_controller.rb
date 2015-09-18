class Users::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  before_action :authenticate_user!
  load_and_authorize_resource :user, find_by: :slug
  layout 'user_profile'

  def new
    @message = @user.messages.build params[:message]
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form' }
      else
        format.html
      end
    end
  end

  def index
    @messages = @user.messages.build
  end

  def create
    @recipients   = Structure.friendly.find(params[:message][:recipients]).admin if params[:message].has_key? :recipients
    @receipt      = @user.send_message_with_label(@recipients, params[:message][:body], params[:message][:subject], Mailboxer::Label::INFORMATION.id) if @recipients
    @conversation = @receipt.conversation if @receipt
    respond_to do |format|
      if @conversation and @conversation.persisted?
        format.html { redirect_to user_conversation_path(@user, @conversation) }
      else
        @message = @user.messages.build params[:message]
        @message.valid?
        format.html { render 'new' }
      end
    end
  end
end
