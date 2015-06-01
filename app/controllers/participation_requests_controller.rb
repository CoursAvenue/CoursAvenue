class ParticipationRequestsController < ApplicationController

  before_action :set_participation_request
  before_action :set_participation_request_url

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

  # GET participation_request/:id/report_form
  def report_form
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

  # PUT participation_request/:id/report
  def report
    @participation_request.update_attributes params[:participation_request]
    respond_to do |format|
      format.html { redirect_to @participation_request_url, notice: "Nous avons bien pris en compte votre signalement" }
    end
  end

  private

  def set_participation_request
    if on_teacher_subdomain?
      @structure             = Structure.find request.subdomain
      @participation_request = @structure.participation_requests.where(token: params[:id]).first
      if @participation_request.nil?
        redirect_to(root_path)
        return
      end
      @user                  = @participation_request.user
    else
      if current_user.nil?
        redirect_to(root_path)
        return
      end
      @participation_request = ParticipationRequest.friendly.find(params[:id])
      @user                  = @participation_request.user
      @structure             = @participation_request.structure
    end
  end

  def set_participation_request_url
    if @participation_request.from_personal_website?
      @participation_request_url = structure_website_participation_request_path(@participation_request)
    else
      @participation_request_url = user_participation_requests_path(@user)
    end
  end
end
