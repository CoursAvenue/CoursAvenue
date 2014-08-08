class Structures::MessagesController < ApplicationController
  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb

  def create
    @structure    = Structure.find params[:structure_id]
    # Retrieve or create user
    @user              = current_user || User.create_or_find_from_email(params[:message][:user][:email], params[:message][:user][:first_name])
    @user.phone_number = params[:message][:user][:phone_number]
    @user.save
    @structure.create_user_profile_for_message(@user)
    @recipients   = @structure.main_contact
    @receipt      = @user.send_message_with_extras(@recipients, params[:message][:body], I18n.t(Mailboxer::Label::INFORMATION.name), 'information', params[:message][:extra_info_ids], params[:message][:course_ids])
    @conversation = @receipt.conversation
    Statistic.action(@structure.id, current_user, cookies[:fingerprint], request.ip, 'contact')
    respond_to do |format|
      if @conversation and @conversation.persisted?
        cookies.delete :user_contact_message
        format.json { render json: { succes: true, popup_to_show: render_to_string(partial: 'structures/messages/message_sent', formats: [:html]) } }
        format.html { redirect_to user_conversation_path(@user, @conversation) }
      elsif current_user
        format.json
        format.html { redirect_to structure_path(@structure, message_body: params[:message][:body]), alert: "Vous n'avez pas remplis toutes les informations" }
      else
        format.json
        format.html { redirect_to structure_path(@structure, message_body: params[:message][:body], first_name: params[:user][:first_name], email: params[:user][:email]), alert: "Vous n'avez pas remplis toutes les informations" }
      end
    end
  end

end
