class Pro::Structures::ParticipationRequestsController < ApplicationController

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure

  layout 'admin'

  # GET pro/etablissements/:structure_id/pass-decouverte-suivi
  def index
    @participation_requests = @structure.participation_requests
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/edit
  def edit
    @participation_request = @structure.participation_requests.find(params[:id])
    render layout: false
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/cancel_form
  def cancel_form
    @participation_request = @structure.participation_requests.find(params[:id])
    render layout: false
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/accept
  def accept
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.accept!(params[:participation_request][:message][:body], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_conversation_path(@structure, @participation_request.conversation), notice: 'Votre message a bien été envoyé' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/modify_date
  def modify_date
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.modify_date!(params[:participation_request][:message][:body], params[:participation_request], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_conversation_path(@structure, @participation_request.conversation), notice: 'Votre message a bien été envoyé' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/decline
  def decline
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.decline!(params[:participation_request][:message][:body], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_conversation_path(@structure, @participation_request.conversation), notice: 'Votre message a bien été envoyé' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/cancel
  def cancel
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.cancel!(params[:participation_request][:message][:body], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_conversation_path(@structure, @participation_request.conversation), notice: 'Votre message a bien été envoyé' }
    end
  end

end
