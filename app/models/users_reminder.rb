class UsersReminder

  def self.send_recommendation(structure, text, _email)
    if (user = User.where(email: _email).first).nil?
      user             = User.new(email: _email)
      structure        = Structure.find(structure.id)
      user.structures << structure
      user.subjects   << structure.subjects
      user.save(validate: false)
    end
    notification           = user.comment_notifications.build
    notification.structure = structure
    if notification.save
      UserMailer.delay.ask_for_feedbacks(structure, text, _email)
    end
  end

  # Resend recommendation email after 4 days
  def self.resend_recommendation_stage_1
    comment_notifications = CommentNotification.where{(updated_at >= Date.today - 4.days) & (updated_at < Date.today - 3.days) & (status == nil)}
    comment_notifications.each{ |comment_notification| comment_notification.ask_for_feedbacks_stage_1 }
  end

  def self.resend_recommendation_stage_2
    comment_notifications = CommentNotification.where{(updated_at >= Date.today - 5.days) & (updated_at < Date.today - 4.days) & (status == 'resend_stage_1')}
    comment_notifications.each{ |comment_notification| comment_notification.ask_for_feedbacks_stage_2 }
  end

  def self.resend_recommendation_stage_3
    comment_notifications = CommentNotification.where{(updated_at >= Date.today - 5.days) & (updated_at < Date.today - 4.days) & (status == 'resend_stage_2')}
    comment_notifications.each{ |comment_notification| comment_notification.ask_for_feedbacks_stage_3 }
  end
end
