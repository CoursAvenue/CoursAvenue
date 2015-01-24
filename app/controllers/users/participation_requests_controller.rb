class Users::ParticipationRequestsController < ApplicationController

  layout 'user_profile'

  before_action :authenticate_user!
  load_and_authorize_resource :user

  # GET eleves/:user_id/participation_request/
  def index
    @past_participation_requests    = (@user.participation_requests.canceled + @user.participation_requests.past).uniq.sort_by(&:date).reverse
    @current_participation_requests = (@user.participation_requests.upcoming.accepted + @user.participation_requests.upcoming.pending).sort_by(&:date)
  end

 # GET eleves/:user_id/participation_request/:id/edit
  def edit
    @participation_request = @user.participation_requests.find(params[:id])
    render layout: false
  end

  # GET eleves/:user_id/participation_request/:id
  def show
    @participation_request = @user.participation_requests.find(params[:id])
    @structure             = @participation_request.structure
  end

  # GET eleves/:user_id/participation_request/:id/accept_form
  def accept_form
    @participation_request = @user.participation_requests.find(params[:id])
    render layout: false
  end

  # GET eleves/:user_id/participation_request/:id/cancel_form
  def cancel_form
    @participation_request = @user.participation_requests.find(params[:id])
    render layout: false
  end

  # GET eleves/:user_id/participation_request/:id/report_form
  def report_form
    @participation_request = @user.participation_requests.find(params[:id])
    render layout: false
  end

  # PUT eleves/:user/participation_request/:id/accept
  def accept
    @participation_request = @user.participation_requests.find(params[:id])
    message_body = params[:participation_request][:message][:body] if params[:participation_request] and params[:participation_request][:message]
    @participation_request.accept!(message_body, 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: "Votre confirmation vient d'être envoyée" }
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

  # PUT eleves/:user/participation_request/:id/discuss
  def discuss
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.discuss!(params[:participation_request][:message][:body], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT eleves/:user/participation_request/:id/cancel
  def cancel
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.cancel!(params[:participation_request][:message][:body], params[:participation_request][:cancelation_reason_id], 'User')
    respond_to do |format|
      format.html { redirect_to (params[:return_to] || user_conversation_path(@user, @participation_request.conversation)), notice: "L'annulation a bien été prise en compte" }
    end
  end

  # PUT eleves/:user/participation_request/:id/report
  def report
    @participation_request = @user.participation_requests.find(params[:id])
    @participation_request.update_attributes params[:participation_request]
    respond_to do |format|
      format.html { redirect_to user_participation_requests_path(@user), notice: "Nous avons bien pris en compte votre signalement" }
    end
  end

  protected

  def layout_locals
    { hide_menu: true }
  end
end
