class Structures::ParticipationRequestsController < ApplicationController
  include ConversationsHelper

  before_action :set_participation_request, except: [:create]
  before_action :set_participation_request_url, except: [:create]

  skip_before_filter  :verify_authenticity_token, only: [:create]

  # For an example of a message controller see:
  # https://github.com/ging/social_stream/blob/master/base/app/controllers/messages_controller.rb
  def create
    @structure = Structure.friendly.find params[:structure_id]
    if params[:participation_request][:user] and
        params[:participation_request][:user][:phone_number].present? and
        params[:participation_request][:user][:phone_number].length < 30 and
        current_user.present?
      current_user.phone_number = params[:participation_request][:user][:phone_number]
      current_user.save
    end
    @structure.create_or_update_user_profile_for_user(current_user, UserProfile::DEFAULT_TAGS[:contacts])
    book_and_send_message
  end

 # GET participation_request/:id/edit
  def edit
    render layout: false
  end

  # GET participation_request/:id/accept_form
  def accept_form
    render layout: false
  end

  # GET participation_request/:id/cancel_form
  def cancel_form
    render layout: false
  end

  # PUT participation_request/:id/accept
  def accept
    message_body = params[:participation_request][:message][:body] if params[:participation_request] and params[:participation_request][:message]
    @participation_request.accept!(message_body, 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || @participation_request_url), notice: "Votre confirmation vient d'être envoyée" }
    end
  end

  # PUT participation_request/:id/modify_date
  def modify_date
    @participation_request.modify_date!(params[:participation_request][:message][:body], params[:participation_request], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || @participation_request_url), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT participation_request/:id/discuss
  def discuss
    @participation_request.discuss!(params[:participation_request][:message][:body], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || @participation_request_url), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT participation_request/:id/cancel
  def cancel
    @participation_request.cancel!(params[:participation_request][:message][:body], params[:participation_request][:cancelation_reason_id], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || @participation_request_url), notice: "L'annulation a bien été prise en compte" }
    end
  end

  private

  def set_participation_request
    @structure             = Structure.friendly.find params[:structure_id]
    @participation_request = @structure.participation_requests.where(token: params[:id]).first
    if @participation_request.nil?
      redirect_to(root_path)
      return
    end
    @user = @participation_request.user
  end

  def set_participation_request_url
    if current_user
      @participation_request_url = user_participation_requests_path(@user)
    else
      @participation_request_url = reservation_structure_participation_request_path(@participation_request.structure, @participation_request)
    end
  end

  def book_and_send_message
    # We use the same routes from structures/participation_request#show and structures#show, so we
    # differentiate using the course_type and manyally set the course_id if necessary.
    if params[:participation_request][:course_type] == 'indexable_card'
      card = IndexableCard.find(params[:participation_request][:course_id])
      params[:participation_request][:course_id] = card.course.id
    end

    @participation_request = ParticipationRequest.create_and_send_message(params[:participation_request], current_user)
    respond_to do |format|
      if @participation_request.persisted?
        format.json { render json: { succes: true, popup_to_show: render_to_string(partial: 'structures/participation_requests/request_sent', formats: [:html]) } }
        # format.html { redirect_to user_conversation_path(current_user, @conversation) }
        format.html { redirect_to checkout_step_3_structure_path(@structure, participation_request_id: @participation_request.id) }
      else
        format.json { render json: { succes: false, popup_to_show: render_to_string(partial: 'structures/participation_requests/request_already_sent', formats: [:html]) }, status: :unprocessable_entity }
        format.html { redirect_to structure_path(@structure, message_body: params[:participation_request][:message][:body]), alert: "Vous avez déjà envoyé ce message" }
      end
    end
  end
end
