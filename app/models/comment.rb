class Comment < ActiveRecord::Base
  attr_accessible :commentable_id, :commentable_type, :content, :author_name, :email, :rating, :title
  belongs_to :commentable, :polymorphic => true

  validates :author_name, :content, presence: true
  validates :rating, numericality: { greater_than: 0, less_than: 6 }

  after_commit :update_commentable_rating

  private
  # Update rating of the commentable (course, or structure)
  def update_commentable_rating
    commentable = self.commentable
    ratings = commentable.comments.group(:rating).count
    nb_rating    = 0
    total_rating = 0
    ratings.delete_if {|k,v| k.nil?}.each do |key, value|
      nb_rating    += value
      total_rating += key * value
    end
    new_rating = (total_rating.to_f / nb_rating.to_f)
    self.commentable.update_attribute :rating, new_rating
  end

end
