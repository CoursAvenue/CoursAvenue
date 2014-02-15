# encoding: utf-8
class Pro::MetricsController < Pro::ProController

  def comments
    render json: Comment.order('created_at DESC').limit(10)
  end

  def comments_count
    render json: { total:           Comment.count,
                   today:           Comment.where{created_at > Date.today}.count,
                   last_seven_days: Comment.where{created_at > 7.days.ago}.count, }
  end

  def jpo_courses_count
    render json: { total:           Course::Open.all.map{|course| course.nb_participants_max * course.plannings.count}.reduce(&:+),
                   today:           Course::Open.where{created_at > Date.today}.map{|course| course.nb_participants_max * course.plannings.count}.reduce(&:+),
                   last_seven_days: Course::Open.where{created_at > 7.days.ago}.map{|course| course.nb_participants_max * course.plannings.count}.reduce(&:+) }
  end

  def reco_count
    render json: { total:           User.active.count,
                   today:           User.active.where{created_at > Date.today}.count,
                   last_seven_days: User.active.where{created_at > 7.days.ago}.count, }
  end

  def users_count
    render json: { total:           CommentNotification.count,
                   today:           CommentNotification.where{created_at > Date.today}.count,
                   last_seven_days: CommentNotification.where{created_at > 7.days.ago}.count, }
  end

  def jpos
    render json: Course::Open.order('created_at DESC').limit(10)
  end
end
