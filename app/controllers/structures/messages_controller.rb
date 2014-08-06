class Structures::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  def create
    @structure    = Structure.find params[:structure_id]
    # Retrieve or create user
    if form_is_valid?
      @user              = current_user || User.create_or_find_from_email(params[:user][:email], params[:user][:first_name])
      @user.phone_number = params[:user][:phone_number]
      @user.save
      @structure.create_user_profile_for_message(@user)
      @recipients   = @structure.main_contact
      @receipt      = @user.send_message_with_extras(@recipients, params[:message][:body], I18n.t(Mailboxer::Label::INFORMATION.name), 'information', params[:message][:extra_info_ids], params[:message][:course_ids])
      @conversation = @receipt.conversation
    end
    Statistic.action(@structure.id, current_user, cookies[:fingerprint], request.ip, 'contact')
    respond_to do |format|
      if @conversation and @conversation.persisted?
        cookies.delete :user_contact_message
        format.html { redirect_to user_conversation_path(@user, @conversation) }
      elsif current_user
        format.html { redirect_to structure_path(@structure, message_body: params[:message][:body]), alert: "Vous n'avez pas remplis toutes les informations" }
      else
        format.html { redirect_to structure_path(@structure, message_body: params[:message][:body], first_name: params[:user][:first_name], email: params[:user][:email]), alert: "Vous n'avez pas remplis toutes les informations" }
      end
      format.js
    end
  end

  private

  # Check if the form is valid
  # params[:content] has to be blank. It is used to prevent from bot form submission
  def form_is_valid?
    if current_user and params[:message][:body].present?
      return true
    else
      return (params[:content].blank? && params[:message][:body].present? && params[:user][:first_name].present? && params[:user][:email].present?)
    end
  end
end
