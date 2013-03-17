class Pro::ReservationLoggersController < Pro::ProController
  layout 'admin'

  def index
    @reservation_loggers = ReservationLogger.order('created_at DESC').all
  end
end
