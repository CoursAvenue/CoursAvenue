class Comment < ActiveRecord::Base
  attr_accessible :commentable_id, :commentable_type, :content, :author_name, :email, :rating, :title

  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  validates :author_name, :content, :commentable, presence: true
  validates :rating, numericality: { greater_than: 0, less_than: 6 }

  before_save   :set_title_if_empty
  after_save    :update_rating
  after_destroy :update_rating

  before_save :replace_slash_n_r_by_brs

  private

  def set_title_if_empty
    if self.commentable.is_a? Course
      self.title = self.commentable.name
    end
  end

  # Update rating of the commentable (course, or structure)
  def update_commentable_rating(_commentable_object)
    if _commentable_object.is_a? Structure
      ratings_array = _commentable_object.all_comments.collect(&:rating)
      ratings       = ratings_array.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
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
    _commentable_object.update_attribute :rating, new_rating
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

end
