class CommentNotification < ActiveRecord::Base
  belongs_to :structure
  belongs_to :user

  validates :structure, :user, presence: true

  # Status:
  #    completed
  #    resend_stage_1
  #    resend_stage_2
  #    resend_stage_3

  def complete!
    self.status = 'completed'
    self.save
  end

  def ask_for_feedbacks_stage_1
    if self.user.email_opt_in
      @structure  = self.structure
      @email      = self.user.email
      self.status = 'resend_stage_1'
      self.save
      UserMailer.delay.ask_for_feedbacks_stage_1(self.structure, @email)
    end
  end

  def ask_for_feedbacks_stage_2
    if self.user.email_opt_in
      @structure  = self.structure
      @email      = self.user.email
      self.status = 'resend_stage_2'
      self.save
      UserMailer.delay.ask_for_feedbacks_stage_2(self.structure, @email)
    end
  end

  def ask_for_feedbacks_stage_3
    if self.user.email_opt_in
      @structure  = self.structure
      @email      = self.user.email
      self.status = 'resend_stage_3'
      self.save
      UserMailer.delay.ask_for_feedbacks_stage_3(self.structure, @email)
    end
  end
end
