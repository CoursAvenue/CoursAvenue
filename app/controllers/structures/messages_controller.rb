class Structures::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  def create
    @structure    = Structure.find params[:structure_id]
    # Retrieve or create user
    if form_is_valid?
      user = current_user || User.create_or_find_from_email(params[:user][:email], params[:user][:first_name])
      @structure.create_user_profile_for_message(user)
      @recipients   = @structure.main_contact
      @receipt      = user.send_message(@recipients, params[:message][:body], "Demande d'informations")
      @conversation = @receipt.conversation
    end
    respond_to do |format|
      if @conversation and @conversation.persisted?
        format.html { redirect_to user_conversation_path(user, @conversation) }
      else
        format.html { redirect_to structure_path(@structure, message_body: params[:message][:body], first_name: params[:user][:first_name], email: params[:user][:email]), alert: "Vous n'avez pas remplis toutes les informations" }
      end
    end
  end

  private

  # Check if the form is valid
  # params[:content] has to be blank. It is used to prevent from bot form submission
  def form_is_valid?
    if current_user
      return true
    else
      return (params[:content].blank? && params[:message][:body].present? && params[:user][:first_name].present? && params[:user][:email].present?)
    end
  end
end
