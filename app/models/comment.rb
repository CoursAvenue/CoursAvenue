class Comment < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :commentable, :commentable_id, :commentable_type, :content, :author_name, :email, :rating, :title, :course_name

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :user

  validates :email, :author_name, :course_name, :rating, :content, :commentable, presence: true
  validates :rating, numericality: { greater_than: 0, less_than: 6 }

  after_initialize :set_default_rating
  after_save       :update_rating
  after_save       :update_teacher_mailchimp if Rails.env.production?
  after_destroy    :update_rating
  after_create     :send_email

  before_save :replace_slash_n_r_by_brs

  scope :ordered, order('created_at DESC')

  def structure
    self.commentable
  end

  def owner?(admin)
    self.commentable == admin.structure
  end

  private

  def set_default_rating
    self.rating = 5
  end

  # Set comments_count to 4 and 14 because after_create is triggered before after_save !
  def send_email
    UserMailer.delay.congratulate_for_comment(self)
    case self.commentable.comments_count
    when 4
      AdminMailer.delay.congratulate_for_fifth_comment(self)
    when 14
      AdminMailer.delay.congratulate_for_fifteenth_comment(self)
    end
    AdminMailer.delay.congratulate_for_comment(self)
  end

  # Update rating of the commentable (course, or structure)
  def update_commentable_rating(_commentable_object)
    # If it is a structure, get ALL the comments
    ratings_array = _commentable_object.comments.collect(&:rating)
    ratings       = ratings_array.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
    _commentable_object.update_comments_count
    nb_rating    = 0
    total_rating = 0
    ratings.delete_if {|k,v| k.nil?}.each do |key, value|
      nb_rating    += value
      total_rating += key * value
    end
    new_rating = (nb_rating == 0 ? nil : (total_rating.to_f / nb_rating.to_f))
    _commentable_object.rating = new_rating
    _commentable_object.save
    _commentable_object.update_comments_count
  end

  def update_rating
    update_commentable_rating(self.commentable)
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
