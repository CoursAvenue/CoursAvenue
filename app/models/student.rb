class Student < ActiveRecord::Base
  include ActsAsUnsubscribable
  acts_as_messageable

  attr_accessible :email, :city, :structure_id, :email_opt_in, :email_status

  belongs_to :structure

  validates :email, uniqueness: {scope: 'structure_id'}

  validates :email, presence: true
  validates :email, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }


  def has_recommanded?
    _email        = self.email
    _structure_id = self.structure_id
    Comment.where{(email == _email) & (commentable_id == _structure_id) & (commentable_type == 'Structure')}.length > 0
  end

  def ask_for_feedbacks_stage_1
    if self.email_opt_in
      @structure        = self.structure
      @email            = self.email
      self.email_status = 'resend_stage_1'
      self.save
      StudentMailer.delay.ask_for_feedbacks_stage_1(self.structure, self.email)
    end
  end

  def ask_for_feedbacks_stage_2
    if self.email_opt_in
      @structure        = self.structure
      @email            = self.email
      self.email_status = 'resend_stage_2'
      self.save
      StudentMailer.delay.ask_for_feedbacks_stage_2(self.structure, self.email)
    end
  end

  def ask_for_feedbacks_stage_3
    if self.email_opt_in
      @structure        = self.structure
      @email            = self.email
      self.email_status = 'resend_stage_3'
      self.save
      StudentMailer.delay.ask_for_feedbacks_stage_3(self.structure, self.email)
    end
  end
end
