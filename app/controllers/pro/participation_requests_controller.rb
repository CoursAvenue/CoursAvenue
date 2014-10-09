# encoding: utf-8
class Pro::ParticipationRequestsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    params[:state] ||= 'pending'
    if params[:state] == 'canceled'
      @participation_requests = ParticipationRequest.where(state: params[:state])
    else
      @participation_requests = ParticipationRequest.where(state: params[:state])
    end
    @participation_requests = Kaminari.paginate_array(@participation_requests).page(params[:page] || 1).per(20)
  end
end
