# encoding: utf-8
class Pro::ParticipationRequestsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    params[:state] ||= 'pending'
    @previous_day_count = ParticipationRequest.
      where(created_at: (Date.yesterday.in_time_zone('Paris')..Date.today.in_time_zone('Paris'))).count
    @participation_requests = ParticipationRequest.order('created_at DESC').where(state: params[:state])
    @participation_requests = Kaminari.paginate_array(@participation_requests).page(params[:page] || 1).per(20)
  end
end
