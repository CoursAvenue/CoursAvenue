class Comment::Reply < Comment

  friendly_id :unique_token, use: [:slugged, :finders]

  belongs_to :commentable, polymorphic: true, touch: true

  def structure
    commentable.try(:structure)
  end

  attr_accessor :show_to_everyone
end
