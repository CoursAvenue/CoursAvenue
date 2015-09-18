class Structures::MessagesController < ApplicationController

  include ConversationsHelper

  skip_before_filter  :verify_authenticity_token, only: [:create]

  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb
  def create
    @structure    = Structure.friendly.find params[:structure_id]
    # Retrieve or create user
    if current_user
      @user = current_user
      if params[:message][:user] and params[:message][:user][:phone_number].present? and params[:message][:user][:phone_number].length < 30
        @user.phone_number = params[:message][:user][:phone_number]
        @user.save
      end
      @structure.create_or_update_user_profile_for_user(@user, UserProfile::DEFAULT_TAGS[:contacts])
      @recipients   = @structure.admin
      if duplicate_message?(@user, params[:message], @structure)
        @conversation = nil
      else
        @receipt      = @user.send_message_with_extras(@recipients, params[:message][:body], I18n.t(Mailboxer::Label::INFORMATION.name), Mailboxer::Label::INFORMATION.id, params[:message][:extra_info_ids], params[:message][:course_ids])
        @conversation = @receipt.conversation
      end
    end
    respond_to do |format|
      if @conversation and @conversation.persisted?
        cookies.delete :user_contact_message
        format.json { render json: { succes: true, popup_to_show: render_to_string(partial: 'structures/messages/message_sent', formats: [:html]) } }
        format.html { redirect_to user_conversation_path(@user, @conversation) }
      elsif @conversation.nil?
        format.json { render json: { succes: false, popup_to_show: render_to_string(partial: 'structures/messages/duplicate_message', formats: [:html]) }, status: :unprocessable_entity }
        format.html { redirect_to structure_path(@structure, message_body: params[:message][:body]), alert: "Vous avez déjà envoyé ce message" }
      elsif current_user
        format.json { render json: { succes: false } }
        format.html { redirect_to structure_path(@structure, message_body: params[:message][:body]), alert: "Vous n'avez pas remplis toutes les informations" }
      else
        format.json { render json: { succes: false } }
        format.html { redirect_to structure_path(@structure, message_body: params[:message][:body], first_name: params[:user][:first_name], email: params[:user][:email]), alert: "Vous n'avez pas remplis toutes les informations" }
      end
    end
  end

end
