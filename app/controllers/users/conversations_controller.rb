class Users::ConversationsController < ApplicationController
  # For an example of a conversation controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/conversations_controller.rb
  before_action :authenticate_user!, except: [:show, :update]
  load_and_authorize_resource :user, find_by: :slug

  layout 'user_profile'

  def show
    @user         = User.find(params[:user_id])
    @conversation = @user.mailbox.conversations.find(params[:id])
    @message      = @conversation.messages.build
    respond_to do |format|
      # If user not active and password token is not valid, kick'em off
      if cannot_see_conversation
        format.html { redirect_to root_path(anchor: 'connection'), alert: 'Vous devez vous connecter pour visualiser le message' }
      # If the slug of the user is wrong (can happen when redirect for facebook connect)
      elsif @user && @user.slug != params[:user_id]
        format.html { redirect_to user_conversation_path(@user, @conversation) }
      else
        format.html
      end
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

  private

  def cannot_see_conversation
    (!@user.active? && !@user.reset_password_token_valid?(params[:token])) || @user.active? and !current_user
  end
end
