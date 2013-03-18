class Pro::ReservationLoggersController < InheritedResources::Base
  layout 'admin'
  actions :index, :destroy

  def index
    @reservation_loggers = ReservationLogger.order('created_at DESC').all
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to reservation_loggers_path }
    end
  end
end
