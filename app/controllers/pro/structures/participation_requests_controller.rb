class Pro::Structures::ParticipationRequestsController < ApplicationController

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure

  layout 'admin'

  # GET pro/etablissements/:structure_id/pass-decouverte-suivi
  def index
    @participation_requests = @structure.participation_requests
    # Select participation request that have the right label id (some could have been flagged as inapropriate
    # and therefore have a different label_id)
    @upcoming_participation_requests = @participation_requests.upcoming
    @past_participation_requests     = @participation_requests.order('date DESC').past
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/edit
  def edit
    @participation_request = @structure.participation_requests.find(params[:id])
    render layout: false
  end

  # GET pro/etablissements/:structure_id/participation_request/:id
  def show
    @participation_request = @structure.participation_requests.find(params[:id])
    @user                  = @participation_request.user
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/cancel_form
  def cancel_form
    @participation_request = @structure.participation_requests.find(params[:id])
    render layout: false
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/report_form
  def report_form
    @participation_request = @structure.participation_requests.find(params[:id])
    render layout: false
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/accept
  def accept
    @participation_request = @structure.participation_requests.find(params[:id])
    message_body = params[:participation_request][:message][:body] if params[:participation_request] and params[:participation_request][:message]
    @participation_request.accept!(message_body, 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_requests_path(@structure), notice: "Votre confirmation vient d'être envoyée" }
    end
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/cancel_form
  def accept_form
    @participation_request = @structure.participation_requests.find(params[:id])
    render layout: false
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/modify_date
  def modify_date
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.modify_date!(params[:participation_request][:message][:body], params[:participation_request], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_requests_path(@structure), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/discuss
  def discuss
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.discuss!(params[:participation_request][:message][:body], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_requests_path(@structure), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/cancel
  def cancel
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.cancel!(params[:participation_request][:message][:body], params[:participation_request][:cancelation_reason_id], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_requests_path(@structure), notice: "La demande d'inscription a bien été refusée" }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/report
  def report
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.update_attributes params[:participation_request]
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_requests_path(@structure), notice: "Nous avons bien pris en compte votre signalement" }
    end
  end

end
