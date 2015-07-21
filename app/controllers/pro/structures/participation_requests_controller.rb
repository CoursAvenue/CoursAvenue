class Pro::Structures::ParticipationRequestsController < ApplicationController

  # We authorize member actions if user is not logged in because we use tokens
  before_action :authenticate_pro_admin!, except: [:show, :edit, :cancel_form, :report_form, :accept,
                                                  :accept_form, :modify_date, :discuss, :cancel,
                                                  :report]
  authorize_resource :structure, except: [:show, :edit, :cancel_form, :report_form, :accept,
                                                  :accept_form, :modify_date, :discuss, :cancel,
                                                  :report]
  before_action :load_structure

  layout 'admin'

  # GET pro/etablissements/:structure_id/pass-decouverte-suivi
  def index
    @participation_requests = @structure.participation_requests
    # Select participation request that have the right label id (some could have been flagged as inapropriate
    # and therefore have a different label_id)
    @upcoming_participation_requests = @participation_requests.upcoming
    @past_participation_requests     = @participation_requests.order('date DESC').past
  end

  # GET pro/etablissements/:structure_id/inscriptions-via-carte-bleu
  def paid_requests
    @participation_requests = @structure.participation_requests.charged
    @needed_informations    = managed_account_missing_informations
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/edit
  def edit
    @participation_request = @structure.participation_requests.find(params[:id])
    render layout: false
  end

  # GET pro/etablissements/:structure_id/participation_request/:id
  def show
    @participation_request = @structure.participation_requests.find(params[:id]).decorate
    @user                  = @participation_request.user
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/show_user_contact
  def show_user_contacts
    @participation_request = @structure.participation_requests.find(params[:id])
    @user                  = @participation_request.user
    @user_decorator        = @user.decorate
    # Treat PR if it is viewed by the teacher and NOT by a super admin
    if @participation_request.pending?
      @participation_request.treat! unless current_pro_admin and current_pro_admin.super_admin?
    end
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
    message_body = params[:participation_request][:message][:body] if params[:participation_request] and params[:participation_request][:message]
    @participation_request.accept!(message_body, 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_request_path(@structure, @participation_request), notice: "Votre confirmation vient d'être envoyée" }
    end
  end

  # GET pro/etablissements/:structure_id/participation_request/:id/accept_form
  def accept_form
    @participation_request = @structure.participation_requests.find(params[:id])
    render layout: false
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/modify_date
  def modify_date
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.modify_date!(params[:participation_request][:message][:body], params[:participation_request], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_request_path(@structure, @participation_request), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/discuss
  def discuss
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.discuss!(params[:participation_request][:message][:body], 'Structure')
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_request_path(@structure, @participation_request), notice: 'Le changement a bien été pris en compte' }
    end
  end

  # PUT pro/etablissements/:structure_id/participation_request/:id/cancel
  def cancel
    @participation_request = @structure.participation_requests.find(params[:id])
    @participation_request.cancel!(params[:participation_request][:message][:body], params[:participation_request][:cancelation_reason_id], 'Structure')

    action_performed = @participation_request.charged? and @participation_request.refunded? ? 'remboursée' : 'refusée'
    respond_to do |format|
      format.html { redirect_to pro_structure_participation_request_path(@structure, @participation_request), notice: "La demande d'inscription a bien été #{ action_performed }" }
    end
  end

  # POST pro/etablissements/:structure_id/participation_request/:id/program_new_class
  def new_class_form
  end

  # POST pro/etablissements/:structure_id/participation_request/:id/program_new_class
  def program_new_class
  end

  # PATCH pro/etablissements/:structure_id/participation_request/:id/signal_user_absence
  def signal_user_absence
  end

  private

  def load_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end

  # The missing informations for the Stripe managed account.
  #
  # @return the fields.
  def managed_account_missing_informations
    return nil if (managed_account = @structure.stripe_managed_account).nil? or
      managed_account.verification.fields_needed.empty?

    fields = managed_account.verification.fields_needed
    if fields.include?('legal_entity.dob.day')
      fields.delete('legal_entity.dob.day')
      fields.delete('legal_entity.dob.month')
      fields.delete('legal_entity.dob.year')
      fields << 'dob'
    end
  end

  def participation_request_attributes
    params.require(:participation_request).permit(:date, :start_time, :end_time)
  end
end
