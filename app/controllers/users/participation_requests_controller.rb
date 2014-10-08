class Users::ParticipationRequestsController < ApplicationController

  layout 'user_profile'

  before_action :authenticate_user!
  load_and_authorize_resource :user

  # GET eleves/:user_id/participation_request/
  def index
    if !current_user.discovery_pass
      redirect_to user_discovery_passes_path(current_user)
    end
    @participation_requests = @user.participation_requests
  end

 # GET eleves/:user_id/participation_request/:id/edit
  def edit
    @participation_request = @user.participation_requests.find(params[:id])
    render layout: false
  end

  # GET eleves/:user_id/participation_request/:id/cancel_form
  def cancel_form
    @participation_request = @user.participation_requests.find(params[:id])
    render layout: false
  end

  # PUT eleves/:user/participation_request/:id/accept
  def accept
    @participation_request = @user.participation_requests.find(params[:id])
    message_body = params[:participation_request][:message][:body] if params[:participation_request] and params[:participation_request][:message]
    @participation_request.accept!(message_body, 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: 'La participation a bien été accepté' }
    end
  end

  # PUT eleves/:user/participation_request/:id/modify_date
  def modify_date
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.modify_date!(params[:participation_request][:message][:body], params[:participation_request], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT eleves/:user/participation_request/:id/cancel
  def cancel
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.cancel!(params[:participation_request][:message][:body], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: "L'annulation a bien été pris en compte" }
    end
  end

  # PUT eleves/:user/participation_request/:id/decline
  def decline
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.decline!(params[:participation_request][:message][:body], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: "Le refus a bien été pris en compte" }
    end
  end

  protected

  def layout_locals
    { hide_menu: true }
  end
end
