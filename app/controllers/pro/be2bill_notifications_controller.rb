# encoding: utf-8
class Pro::Be2billNotificationsController < Pro::ProController

  def index
    @notifications = Be2billNotification.all
  end

  def show
    @notification = Be2billNotification.find params[:id]
  end

end
