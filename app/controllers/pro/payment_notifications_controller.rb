# encoding: utf-8
class Pro::PaymentNotificationsController < Pro::ProController

  def index
    @notifications = PaymentNotification::Be2bill.all
  end

  def show
    @notification = PaymentNotification::Be2bill.find params[:id]
  end

end
