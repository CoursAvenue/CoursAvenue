# encoding: utf-8
class Pro::CommentNotificationsController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  def index
    @comment_notifications = CommentNotification.order('created_at DESC')
    @comment_notifications = Kaminari.paginate_array(@comment_notifications).page(params[:page] || 1).per(50)
  end
end
