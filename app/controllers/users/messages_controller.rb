class Users::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  before_action :authenticate_user!, except: [:see_message]

  layout 'user_profile'

  def new
    @message = current_user.messages.build params[:message]
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form' }
      else
        format.html
      end
    end
  end

  def index
    @messages = current_user.messages.build
  end

  def create
    @recipients   = Structure.find(params[:message][:recipients]).main_contact if params[:message].has_key? :recipients
    @receipt      = current_user.send_message(@recipients, params[:message][:body], params[:message][:subject]) if @recipients and @recipients.any?
    @conversation = @receipt.conversation if @receipt
    respond_to do |format|
      if @conversation and @conversation.persisted?
        format.html { redirect_to user_conversation_path(current_user, @conversation) }
      else
        @message = current_user.messages.build
        render 'new'
      end
    end
  end
end
