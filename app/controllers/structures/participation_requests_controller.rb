class Structures::ParticipationRequestsController < ApplicationController

  include ConversationsHelper

  skip_before_filter  :verify_authenticity_token, only: [:create]

  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb
  def create
    @structure = Structure.find params[:structure_id]
    if params[:participation_request][:user] and params[:participation_request][:user][:phone_number].present? and params[:participation_request][:user][:phone_number].length < 30
      current_user.phone_number = params[:participation_request][:user][:phone_number]
      current_user.save
    end
    @structure.create_or_update_user_profile_for_user(current_user, UserProfile::DEFAULT_TAGS[:contacts])
    book_and_send_message
  end

  def book_and_send_message
    @participation_request = ParticipationRequest.create_and_send_message params[:participation_request], params[:participation_request][:message][:body], current_user, @structure
    respond_to do |format|
      if @participation_request.persisted?
        Metric.action(@structure.id, cookies[:fingerprint], request.ip, 'participation_request')
        format.json { render json: { succes: true, popup_to_show: render_to_string(partial: 'structures/participation_requests/request_sent', formats: [:html]) } }
        format.html { redirect_to user_conversation_path(current_user, @conversation) }
      else
        format.json { render json: { succes: false, popup_to_show: render_to_string(partial: 'structures/participation_requests/request_already_sent', formats: [:html]) }, status: :unprocessable_entity }
        format.html { redirect_to structure_path(@structure, message_body: params[:participation_request][:message][:body]), alert: "Vous avez déjà envoyé ce message" }
      end
    end

  end

end
