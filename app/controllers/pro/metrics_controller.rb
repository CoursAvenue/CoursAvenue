# encoding: utf-8
class Pro::MetricsController < Pro::ProController

  def comments
    render json: Comment.order('created_at DESC').limit(10)
  end

  def comments_count
    render json: { total:           Comment.count,
                   today:           Comment.where( Comment.arel_table[:created_at].gt(Date.today) ).count,
                   last_seven_days: Comment.where( Comment.arel_table[:created_at].gt(7.days.ago) ).count, }
  end

  def admins_count
    render json: { total:           Admin.normal.count,
                   today:           Admin.normal.where( Admin.arel_table[:created_at].gt(Date.today) ).count,
                   last_seven_days: Admin.normal.where( Admin.arel_table[:created_at].gt(7.days.ago) ).count, }
  end

  def jpo_courses_count
    render json: { total:           Course::Open.all.map{|course| course.nb_participants_max * course.plannings.count}.reduce(&:+),
                   today:           Course::Open.where( Course::Open.arel_table[:created_at].gt(Date.today) ).map{|course| course.nb_participants_max * course.plannings.count}.reduce(&:+),
                   last_seven_days: Course::Open.where( Course::Open.arel_table[:created_at].gt(7.days.ago) ).map{|course| course.nb_participants_max * course.plannings.count}.reduce(&:+) }
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

  def jpos
    render json: Course::Open.order('created_at DESC').limit(10)
  end
end
