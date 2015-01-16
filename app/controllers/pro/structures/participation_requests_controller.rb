class Pro::Structures::ParticipationRequestsController < ApplicationController

  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure

  layout 'admin'

  # GET pro/etablissements/:structure_id/pass-decouverte-suivi
  def index
    @participation_requests = @structure.participation_requests
    # Select participation request that have the right label id (some could have been flagged as inapropriate
    # and therefore have a different label_id)
    @upcoming_participation_requests = @participation_requests.order('date ASC').upcoming.select{ |pr| pr.conversation.mailboxer_label_id == Mailboxer::Label::REQUEST.id }
    @past_participation_requests     = @participation_requests.order('date DESC').past.select{ |pr| pr.conversation.mailboxer_label_id == Mailboxer::Label::REQUEST.id }
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

  # PUT pro/etablissements/:structure_id/participation_request/:id/accept
  def accept
    @participation_request = @structure.participation_requests.find(params[:id])
    message_body = params[:participation_request][:message][:body] if params[:participation_request] and params[:participation_request][:message]
    @participation_request.accept!(message_body, 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_conversation_path(@structure, @participation_request.conversation), notice: "Votre confirmation vient d'être envoyée" }
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
      format.html { redirect_to pro_structure_conversation_path(@structure, @participation_request.conversation), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/decline
  def decline
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.decline!(params[:participation_request][:message][:body], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_conversation_path(@structure, @participation_request.conversation), notice: 'Le refus a bien été envoyé' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/cancel
  def cancel
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.cancel!(params[:participation_request][:message][:body], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_conversation_path(@structure, @participation_request.conversation), notice: "L'annulation a bien été pris en compte" }
    end
  end

end
