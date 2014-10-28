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
    if params[:participation_request][:request_type] == 'booking'
      book_and_send_message
    else
      send_message
    end
  end

  def send_message
    @recipients   = @structure.main_contact
    if duplicate_message?(current_user, params[:participation_request][:message], @structure)
      @conversation = nil
    else
      @receipt      = current_user.send_message_with_extras(@recipients, params[:participation_request][:message][:body], I18n.t(Mailboxer::Label::INFORMATION.id), Mailboxer::Label::INFORMATION.id, params[:participation_request][:message][:extra_info_ids], params[:participation_request][:message][:course_ids])
      @conversation = @receipt.conversation
    end
    respond_to do |format|
      if @conversation and @conversation.persisted?
        Metric.action(@structure.id, current_user, cookies[:fingerprint], request.ip, 'contact_message')
        cookies.delete :user_contact_message
        format.json { render json: { succes: true, popup_to_show: render_to_string(partial: 'structures/messages/message_sent', formats: [:html]) } }
        format.html { redirect_to user_conversation_path(current_user, @conversation) }
      elsif @conversation.nil?
        format.json { render json: { succes: false, popup_to_show: render_to_string(partial: 'structures/messages/duplicate_message', formats: [:html]) }, status: :unprocessable_entity }
        format.html { redirect_to structure_path(@structure, message_body: params[:participation_request][:message][:body]), alert: "Vous avez déjà envoyé ce message" }
      elsif current_user
        format.json { render json: { succes: false } }
        format.html { redirect_to structure_path(@structure, message_body: params[:participation_request][:message][:body]), alert: "Vous n'avez pas remplis toutes les informations" }
      else
        format.json { render json: { succes: false } }
        format.html { redirect_to structure_path(@structure, message_body: params[:participation_request][:message][:body], first_name: params[:user][:first_name], email: params[:user][:email]), alert: "Vous n'avez pas remplis toutes les informations" }
      end
    end
  end

  def book_and_send_message
    if params[:participation_request][:planning_id].blank? and params[:participation_request][:start_hour] and params[:participation_request][:start_min]
      # Be careful to add 0 at the end to remove local time.
      params[:participation_request][:start_time] = Time.new(2000, 1, 1, params[:participation_request][:start_hour].to_i, params[:participation_request][:start_min].to_i, 0, 0)
      params[:participation_request].delete(:start_hour)
      params[:participation_request].delete(:start_min)
    end
    @participation_request = ParticipationRequest.create_and_send_message params[:participation_request], params[:participation_request][:message][:body], current_user, @structure

    respond_to do |format|
      if @participation_request.persisted?
        Metric.action(@structure.id, current_user, cookies[:fingerprint], request.ip, 'participation_request')
        format.json { render json: { succes: true, popup_to_show: render_to_string(partial: 'structures/participation_requests/request_sent', formats: [:html]) } }
        format.html { redirect_to user_conversation_path(current_user, @conversation) }
      else
        format.json { render json: { succes: false, popup_to_show: render_to_string(partial: 'structures/participation_requests/request_already_sent', formats: [:html]) }, status: :unprocessable_entity }
        format.html { redirect_to structure_path(@structure, message_body: params[:participation_request][:message][:body]), alert: "Vous avez déjà envoyé ce message" }
      end
    end

  end

end
