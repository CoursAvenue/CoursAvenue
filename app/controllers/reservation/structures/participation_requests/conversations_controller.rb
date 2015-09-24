class Reservation::Structures::ParticipationRequests::ConversationsController < ReservationController
  include ConversationsHelper

  load_resource :participation_request, find_by: :token

  def update
    @user         = @participation_request.user
    @conversation = @participation_request.conversation
    @user.reply_to_conversation(@conversation, params[:conversation][:message][:body]) if params[:conversation][:message][:body].present?
    respond_to do |format|
      if params[:conversation][:message][:body].blank?
        format.html { redirect_to reservation_structure_participation_request_path(@participation_request.structure, @participation_request.token), alert: 'Vous ne pouvez pas envoyer de message vide' }
      else
        format.html { redirect_to reservation_structure_participation_request_path(@participation_request.structure, @participation_request.token), notice: 'Message envoyé' }
      end
    end
  end

end
