class Users::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  before_action :authenticate_user!, except: [:see_message]

  layout 'user_profile'

  def see_message
  end

  def new
    @message = current_user.messages.build
  end

  def index
    @messages = current_user.messages.build
  end

  def create
    @recipients   = Structure.find(params[:message][:recipients]).main_contact
    @receipt      = current_user.send_message(@recipients, params[:message][:body], params[:message][:subject])
    @conversation = @receipt.conversation
    respond_to do |format|
      if @conversation.persisted?
        format.html { redirect_to user_conversation_path(current_user, @conversation) }
      else
        @message = current_user.messages.build
        render 'new'
      end
    end
  end
end
