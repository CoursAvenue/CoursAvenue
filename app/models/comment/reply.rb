class Comment::Reply < Comment

  friendly_id :unique_token, use: [:slugged, :finders]

  belongs_to :commentable, polymorphic: true, touch: true

  attr_accessor :show_to_everyone

  def structure
    commentable.try(:structure)
  end

end
