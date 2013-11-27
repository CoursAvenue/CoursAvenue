class Structures::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  def create
    # params[:content] has to be blank. It is used to prevent from bot form submission
    if params[:content].present?
      valid = false
    elsif current_user.present?
      valid = true
    else
      valid = (params[:user][:name].present? and params[:user][:email].present?)
    end
    @structure    = Structure.find params[:structure_id]
    if valid
      user_email    = params[:user][:email] unless current_user
      @user         = current_user || User.where{email == user_email}.first || User.new(email: params[:user][:email].downcase, name: params[:user][:name])
      @user.save(validate: false) if @user.new_record?
      @recipients   = @structure.main_contact
      @receipt      = @user.send_message(@recipients, params[:message][:body], "Demande d'informations")
      @conversation = @receipt.conversation
    end
    respond_to do |format|
      if valid and @conversation.persisted?
        @token       = @user.generate_and_set_reset_password_token if !@user.active?
        format.html { redirect_to user_conversation_path(@user, @conversation, token: @token) }
      else
        format.html { redirect_to structure_path(@structure), alert: "Vous n'avez pas remplis toutes les informations" }
      end
    end
  end

end
