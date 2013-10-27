# encoding: utf-8
class UsersController < InheritedResources::Base
  layout 'user_profile'
  actions :show, :update

  load_and_authorize_resource :user, find_by: :slug, except: [:first_update]

  def show
    @user = User.find(params[:id])
  end

  def update
    update! do |format|
      format.html { redirect_to user_path(current_user), notice: 'Votre profil a bien été mis à jour.' }
    end
  end

  def first_update
    @user = User.find(params[:id])
    if @user.reset_password_token_valid?(params[:reset_password_token]) and params[:user][:password].present?
      conversation = @user.mailbox.conversations.last
      @user.update_attributes(params[:user])
      @user.reply_to_conversation(conversation, params[:message])
      sign_in @user, :bypass => true
      redirect_to user_conversation_path(current_user, conversation), notice: 'Vous êtes maintenant connecté.'
    else
      redirect_to root_path, alert: "Vous n'avez pas la permission"
    end
  end
end
