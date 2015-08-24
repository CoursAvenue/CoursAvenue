class Comment::Reply < Comment

  friendly_id :unique_token, use: [:slugged, :finders]

  belongs_to :commentable, polymorphic: true, touch: true

  has_one :structure, through: :commentable

  attr_accessor :show_to_everyone
end
