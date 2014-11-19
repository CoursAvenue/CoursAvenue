class Comment < ActiveRecord::Base
  extend FriendlyId

  friendly_id :unique_token, use: [:slugged, :finders]

  acts_as_paranoid

  attr_accessible :commentable, :commentable_id, :commentable_type, :content, :type

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :commentable, polymorphic: true, touch: true

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :content, :commentable, presence: true

  private

  def unique_token
    loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Comment::Review.exists?(slug: random_token)
    end
  end

end
