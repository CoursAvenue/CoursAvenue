class CommentNotification < ActiveRecord::Base
  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :structure
  belongs_to :user

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validate :structure_has_to_be_present
  validates :user, presence: true
  validates :user, uniqueness: { scope: [:structure_id, :notification_for] }

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :ask_for_recommandations

  attr_accessible :user, :structure, :notification_for, :text

  # Status:
  #    completed
  #    resend_stage_1
  #    resend_stage_2
  #    resend_stage_3

  def complete!
    self.status = 'completed'
    self.save
  end

  def complete?
    self.status == 'completed'
  end

  def ask_for_recommandations_stage_1
    if self.user.email_opt_in
      self.status = 'resend_stage_1'
      self.save
      UserMailer.delay(queue: 'mailers').ask_for_recommandations_stage_1(self)
    end
  end

  def ask_for_recommandations_stage_2
    if self.user.email_opt_in
      self.status = 'resend_stage_2'
      self.save
      UserMailer.delay(queue: 'mailers').ask_for_recommandations_stage_2(self)
    end
  end

  def ask_for_recommandations_stage_3
    if self.user.email_opt_in
      self.status = 'resend_stage_3'
      self.save
      UserMailer.delay(queue: 'mailers').ask_for_recommandations_stage_3(self)
    end
  end

  private

  def ask_for_recommandations
    if self.user.email_opt_in
      UserMailer.delay(queue: 'mailers').ask_for_recommandations(self)
    end
  end

  private

  def structure_has_to_be_present
    if notification_for.nil? and structure.nil?
      self.errors.add :structure, :blank
    end
  end
end
