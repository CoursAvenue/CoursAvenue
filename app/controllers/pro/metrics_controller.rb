# encoding: utf-8
class Pro::MetricsController < Pro::ProController

  def comments
    render json: Comment::Review.order('created_at DESC').limit(10)
  end

  def comments_count
    render json: { total:           Comment::Review.count,
                   today:           Comment::Review.where( Comment::Review.arel_table[:created_at].gt(Date.today) ).count,
                   last_seven_days: Comment::Review.where( Comment::Review.arel_table[:created_at].gt(7.days.ago) ).count, }
  end

  def admins_count
    render json: { total:           Admin.normal.count,
                   today:           Admin.normal.where( Admin.arel_table[:created_at].gt(Date.today) ).count,
                   last_seven_days: Admin.normal.where( Admin.arel_table[:created_at].gt(7.days.ago) ).count, }
  end

  def reco_count
    render json: { total:           CommentNotification.count,
                   today:           CommentNotification.where( CommentNotification.arel_table[:created_at].gt(Date.today) ).count,
                   last_seven_days: CommentNotification.where( CommentNotification.arel_table[:created_at].gt(7.days.ago) ).count, }
  end

  def users_count
    render json: { total:           User.active.count,
                   today:           User.active.where( User.arel_table[:created_at].gt(Date.today) ).count,
                   last_seven_days: User.active.where( User.arel_table[:created_at].gt(7.days.ago) ).count, }
  end

end
