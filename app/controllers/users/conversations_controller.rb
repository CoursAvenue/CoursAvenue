class Users::ConversationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_user!, except: [:show, :update]

  layout 'user_profile'

  def show
    @user = current_user || User.find(params[:user_id])
    @conversation = @user.mailbox.conversations.find(params[:id])
    @message      = @conversation.messages.build
    respond_to do |format|
      if !current_user and !@user.reset_password_token_valid?(params[:token])
        format.html { redirect_to root_path, alert: 'Vous ne pouvez pas visualiser cette page' }
      elsif current_user and current_user.slug != params[:user_id]
        format.html { redirect_to user_conversation_path(current_user, @conversation)}
      else
        format.html
      end
    end
  end

  def index
    @conversations = current_user.mailbox.conversations
  end

  def new
    @conversation = current_user.mailbox.conversations.build
    @message      = @conversation.messages.build
  end

  def update
    @user = User.find(params[:user_id])
    if params[:password]
      if @user.reset_password_token_valid?(params[:reset_password_token])
        @user.password = params[:password]
        @user.save
        sign_in(@user, bypass: true)
        flash[:notice] = "Votre message à bien été envoyé et vous êtes maintenant connecté."
      else
        flash[:alert] = "Le token n'est pas valide, vous ne pouvez pas changer votre mot de passe."
      end
    end
    if @user.active?
      @conversation = @user.mailbox.conversations.find params[:id]
      @user.reply_to_conversation(@conversation, params[:conversation][:message][:body])
    end
    respond_to do |format|
      format.html { redirect_to user_conversation_path(@user, @conversation) }
    end
  end
end
