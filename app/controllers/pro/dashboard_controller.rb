# encoding: utf-8
class Pro::DashboardController < Pro::ProController
  def index
    authorize! :manage, ClickLogger
    @reservations_logger = ReservationLogger.order("DATE(created_at)").group("DATE(created_at)").count
    @renting_rooms       = RentingRoom.all
    @click_logger        = ClickLogger.group('name').count
  end
end
