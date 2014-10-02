class Users::ParticipationRequestsController < ApplicationController

  layout 'user_profile'

  before_action :authenticate_user!
  load_and_authorize_resource :user

  # GET eleves/:user_id/participation_request/
  def index
    @participation_requests = @user.participation_requests
  end

 # GET eleves/:user_id/participation_request/:id/edit
  def edit
    @participation_request = @user.participation_requests.find(params[:id])
    render layout: false
  end

  # GET eleves/:user_id/participation_request/:id/decline_form
  def decline_form
    @participation_request = @user.participation_requests.find(params[:id])
    render layout: false
  end

  # PUT eleves/:user/participation_request/:id/accept
  def accept
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.accept!(params[:participation_request][:message][:body], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: 'Votre message a bien été envoyé' }
    end
  end

  # PUT eleves/:user/participation_request/:id/modify_date
  def modify_date
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.modify_date!(params[:participation_request][:message][:body], params[:participation_request], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: 'Votre message a bien été envoyé' }
    end
  end

  # PUT eleves/:user/participation_request/:id/decline
  def decline
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.decline!(params[:participation_request][:message][:body], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: 'Votre message a bien été envoyé' }
    end
  end

  protected

  def layout_locals
    { hide_menu: true }
  end
end
