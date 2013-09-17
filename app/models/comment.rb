class Comment < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :commentable, :commentable_id, :commentable_type, :content, :author_name, :email, :rating,
                  :title, :course_name,
                  :validated

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :user

  validates :email, :author_name, :course_name, :rating, :content, :commentable, presence: true
  validates :rating, numericality: { greater_than: 0, less_than: 6 }

  after_initialize :set_default_rating
  after_save       :update_teacher_mailchimp if Rails.env.production?
  after_destroy    :update_rating
  before_create    :set_pending_status
  after_create     :send_email

  before_save      :replace_slash_n_r_by_brs
  before_save      :strip_names

  scope :ordered,   order('created_at DESC')

  scope :pending,              where(status: 'pending')
  scope :accepted,             where(status: 'accepted')
  scope :waiting_for_deletion, where(status: 'waiting_for_deletion')


  def accept! silent=false
    self.status = :accepted
    self.save
    self.update_rating
    unless silent
      case self.commentable.comments_count
      when 5
        AdminMailer.delay.congratulate_for_fifth_comment(self)
      when 15
        AdminMailer.delay.congratulate_for_fifteenth_comment(self)
      end

      self.notify_student
    end
  end

  def decline!
    self.status = :declined
    self.save
    self.update_rating
  end

  def ask_for_deletion!
    self.status = :waiting_for_deletion
    self.save
    self.update_rating
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
  def update_rating
    # If it is a structure, get ALL the comments
    ratings_array = self.commentable.comments.accepted.collect(&:rating)
    ratings       = ratings_array.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
    nb_rating    = 0
    total_rating = 0
    ratings.delete_if {|k,v| k.nil?}.each do |key, value|
      nb_rating    += value
      total_rating += key * value
    end
    new_rating = (nb_rating == 0 ? nil : (total_rating.to_f / nb_rating.to_f))
    self.commentable.update_column :rating, new_rating
    self.commentable.update_comments_count
  end

  protected

  def set_pending_status
    if self.structure and self.email
      _structure_id = self.structure.id
      _email        = self.email
      if Student.where{(structure_id == _structure_id) & (email == _email)}.count > 0
        self.status = 'accepted'
        self.update_rating
      end
    end
    self.status ||= 'pending'
  end

  def notify_student
    UserMailer.delay.comment_has_been_validated(self)
  end

  private

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
