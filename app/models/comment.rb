class Comment < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :commentable, :commentable_id, :commentable_type, :content, :author_name, :email, :rating, :title

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :author_name, :rating, :content, :commentable, presence: true
  validates :rating, numericality: { greater_than: 0, less_than: 6 }

  before_save   :set_title_if_empty
  after_save    :update_rating
  after_save    :update_users_mailchimp   if Rails.env.production?
  after_save    :update_teacher_mailchimp if Rails.env.production?
  after_destroy :update_rating

  before_save :replace_slash_n_r_by_brs


  def structure
    if self.commentable.is_a? Structure
      self.commentable
    else
      self.commentable.structure
    end
  end

  private

  def set_title_if_empty
    if self.commentable.is_a? Course
      self.title = self.commentable.name
    end
  end

  # Update rating of the commentable (course, or structure)
  def update_commentable_rating(_commentable_object)
    # If it is a strcuture, get ALL the comments
    if _commentable_object.is_a? Structure
      ratings_array = _commentable_object.all_comments.collect(&:rating)
      ratings       = ratings_array.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
      _commentable_object.update_comments_count
    else
      ratings = _commentable_object.comments.group(:rating).count
    end
    nb_rating    = 0
    total_rating = 0
    ratings.delete_if {|k,v| k.nil?}.each do |key, value|
      nb_rating    += value
      total_rating += key * value
    end
    new_rating = (nb_rating == 0 ? nil : (total_rating.to_f / nb_rating.to_f))
    _commentable_object.rating = new_rating
    _commentable_object.save
    if _commentable_object.is_a? Structure
      _commentable_object.update_comments_count
    end
  end

  def update_rating
    update_commentable_rating(self.commentable)
    if commentable.is_a? Course
      update_commentable_rating(commentable.structure)
    end
  end

  def replace_slash_n_r_by_brs
    self.content = self.content.gsub(/\r\n/, '<br>')
  end

  def update_users_mailchimp
    user_email = self.email || self.user.email
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_USERS_LIST_ID,
                           :email_address => user_email,
                           :merge_vars => {
                              :NB_COMMENT => Comment.where{email == user_email}.count
                            },
                           :double_optin => false,
                           :update_existing => true,
                           :send_welcome => false}
                           )

  end
  def update_teacher_mailchimp
    strcuture = self.commentable
    if strcuture.is_a? Course
      strcuture = strcuture.structure
    end
    nb_comments = strcuture.all_comments.length
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_TEACHERS_LIST_ID,
                           :email_address => strcuture.contact_email,
                           :merge_vars => {
                              :NB_COMMENT => nb_comments
                           },
                           :double_optin => false,
                           :update_existing => true,
                           :send_welcome => false}
                           )

  end
end
