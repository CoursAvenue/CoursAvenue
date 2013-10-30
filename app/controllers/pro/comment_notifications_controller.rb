# encoding: utf-8
class Pro::CommentNotificationsController < Pro::ProController
  before_action :authenticate_pro_admin!

  layout 'admin'

  def index
    @comment_notifications = CommentNotification.order('created_at DESC').limit(500)
  end
end
