class Structures::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  def create
    @structure    = Structure.find params[:structure_id]
    # Retrieve or create user
    if form_is_valid?
      @structure.create_user_profile_for_message(current_user)
      @recipients   = @structure.main_contact
      @receipt      = current_user.send_message(@recipients, params[:message][:body], "Demande d'informations")
      @conversation = @receipt.conversation
    end
    respond_to do |format|
      if @conversation and @conversation.persisted?
        format.html { redirect_to user_conversation_path(current_user, @conversation) }
      else
        format.html { redirect_to structure_path(@structure), alert: "Vous n'avez pas remplis toutes les informations" }
      end
    end
  end

  private

  # Check if the form is valid
  # params[:content] has to be blank. It is used to prevent from bot form submission
  def form_is_valid?
    if params[:content].present?
      valid = false
    elsif current_user.present?
      valid = true
    end
    valid
  end
end
