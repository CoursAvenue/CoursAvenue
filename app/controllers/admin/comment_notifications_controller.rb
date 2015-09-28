# encoding: utf-8
class Admin::CommentNotificationsController < Admin::AdminController
  def index
    @comment_notifications = CommentNotification.order('created_at DESC')
    @comment_notifications = Kaminari.paginate_array(@comment_notifications).page(params[:page] || 1).per(50)
  end
end
