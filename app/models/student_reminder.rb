class StudentReminder

  # Resend recommendation email after 4 days
  def self.resend_recommendation_stage_1
    students = Student.where{(updated_at > (Date.today - 3.days)) & (email_status == nil) & (structure_id != nil)}
    students = students.reject do |student|
      Comment.where(email: student.email).count > 0
    end
    students.each{ |student| student.ask_for_feedbacks_stage_1 }
  end

  def self.resend_recommendation_stage_2
    students = Student.where{(updated_at >= Date.today - 4.days) & (updated_at < Date.today - 3.days) & (email_status == 'resend_stage_1') & (structure_id != nil)}
    students = students.reject do |student|
      Comment.where(email: student.email).count > 0
    end
    students.each{ |student| student.ask_for_feedbacks_stage_2 }
  end

  def self.resend_recommendation_stage_3
    students = Student.where{(updated_at >= Date.today - 5.days) & (updated_at < Date.today - 4.days) & (email_status == 'resend_stage_2') & (structure_id != nil)}
    students = students.reject do |student|
      Comment.where(email: student.email).count > 0
    end
    students.each{ |student| student.ask_for_feedbacks_stage_3 }
  end
end
