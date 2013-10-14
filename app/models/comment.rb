class Comment < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :commentable, :commentable_id, :commentable_type, :content, :author_name, :email, :rating,
                  :title, :course_name,
                  :validated
  # A comment has a status which can be one of the following:
  #   - pending
  #   - accepted
  #   - waiting_for_deletion

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :user

  validates :email, :author_name, :course_name, :rating, :content, :commentable, presence: true
  validates :rating, numericality: { greater_than: 0, less_than: 6 }
  validate  :doesnt_exist_yet, on: :create

  after_initialize :set_default_rating
  after_save       :update_teacher_mailchimp if Rails.env.production?
  after_destroy    :update_comments_count
  before_create    :set_pending_status
  after_create     :send_email

  before_save      :replace_slash_n_r_by_brs
  before_save      :strip_names
  before_save      :downcase_email

  after_save       :update_comments_count

  scope :ordered,              -> { order('created_at DESC') }
  scope :pending,              -> { where(status: 'pending') }
  scope :accepted,             -> { where(status: 'accepted') }
  scope :waiting_for_deletion, -> { where(status: 'waiting_for_deletion') }

  def content_for_input
    self.content.gsub(/<br>/, '&#x000A;').html_safe if self.content
  end

  def recover!
    self.status = :accepted
    self.save
  end

  def accept!
    self.status = :accepted
    self.save
    case self.commentable.comments_count
    when 5
      AdminMailer.delay.congratulate_for_fifth_comment(self)
    when 15
      AdminMailer.delay.congratulate_for_fifteenth_comment(self)
    end
    self.notify_student
  end

  def decline!
    self.status = :declined
    self.save
  end

  def ask_for_deletion!(deletion_reason=nil)
    self.status          = :waiting_for_deletion
    self.deletion_reason = deletion_reason if deletion_reason
    self.save
    AdminMailer.delay.ask_for_deletion(self)
  end

  def waiting_for_deletion?
    self.status == 'waiting_for_deletion'
  end

  def accepted?
    self.status == 'accepted'
  end

  def pending?
    self.status == 'pending'
  end

  def declined?
    self.status == 'declined'
  end

  def structure
    self.commentable
  end

  def owner?(admin)
    self.commentable == admin.structure
  end

  # Update rating of the commentable (course, or structure)
  def update_comments_count
    self.commentable.update_comments_count
  end

  protected

  def set_pending_status
    if self.structure and self.email
      _structure_id = self.structure.id
      _email        = self.email
      if Student.where{(structure_id == _structure_id) & (email == _email)}.count > 0
        self.status = 'accepted'
      end
    end
    self.status ||= 'pending'
  end

  def notify_student
    UserMailer.delay.comment_has_been_validated(self)
  end

  private

  def doesnt_exist_yet
    _structure_id = self.commentable_id
    _email        = self.email
    if Comment.where{(commentable_id == _structure_id) & (email == _email) & (created_at > 2.months.ago)}.any?
      self.errors.add :email, I18n.t('comments.errors.already_posted')
    end
  end

  def strip_names
    self.author_name = self.author_name.strip if author_name.present?
    self.title       = self.title.strip       if title.present?
    self.course_name = self.course_name.strip if course_name.present?
  end

  def set_default_rating
    self.rating = 5
  end

  # Set comments_count to 4 and 14 because after_create is triggered before after_save !
  def send_email
    if self.accepted?
      AdminMailer.delay.congratulate_for_accepted_comment(self)
      UserMailer.delay.congratulate_for_accepted_comment(self)
    else
      AdminMailer.delay.congratulate_for_comment(self)
      UserMailer.delay.congratulate_for_comment(self)
    end
  end


  def replace_slash_n_r_by_brs
    self.content = self.content.gsub(/\r\n/, '<br>')
  end

  def downcase_email
    self.email = self.email.downcase
  end

  def update_teacher_mailchimp
    structure = self.commentable
    nb_comments = structure.comments.count
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_TEACHERS_LIST_ID,
                           :email_address => structure.contact_email,
                           :merge_vars => {
                              :NB_COMMENT => nb_comments
                           },
                           :double_optin => false,
                           :update_existing => true,
                           :send_welcome => false}
                           )

  end
end
