# encoding: utf-8
class Pro::ParticipationRequestsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    params[:state] ||= 'pending'
    @participation_requests = ParticipationRequest.includes(:state).joins(:state).
      where("participation_request_states.state LIKE ?", params[:state]).
      order('participation_requests.created_at DESC')
    @participation_requests = Kaminari.paginate_array(@participation_requests).page(params[:page] || 1).per(20)
  end
end
