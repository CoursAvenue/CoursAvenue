class UsersReminder

  # Resend recommendation email after 4 days
  def self.resend_recommendation_stage_1
    comment_notifications = CommentNotification.where( CommentNotification.arel_table[:updated_at].gteq(Date.today - 4.days).and(
                                                       CommentNotification.arel_table[:updated_at].lt(Date.today - 3.days).and(
                                                       CommentNotification.arel_table[:status].eq(nil))) )
    comment_notifications.each{ |comment_notification| comment_notification.ask_for_recommandations_stage_1 }
  end

  def self.resend_recommendation_stage_2
    comment_notifications = CommentNotification.where( CommentNotification.arel_table[:updated_at].gteq(Date.today - 5.days).and(
                                                       CommentNotification.arel_table[:updated_at].lt(Date.today - 4.days).and(
                                                       CommentNotification.arel_table[:status].eq('resend_stage_1'))) )
    comment_notifications.each{ |comment_notification| comment_notification.ask_for_recommandations_stage_2 }
  end

  def self.resend_recommendation_stage_3
    comment_notifications = CommentNotification.where( CommentNotification.arel_table[:updated_at].gteq(Date.today - 5.days).and(
                                                       CommentNotification.arel_table[:updated_at].lt(Date.today - 4.days).and(
                                                       CommentNotification.arel_table[:status].eq('resend_stage_2'))) )
    comment_notifications.each{ |comment_notification| comment_notification.ask_for_recommandations_stage_3 }
  end
end
