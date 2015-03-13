class Comment::Reply < Comment

  belongs_to :commentable, polymorphic: true

  has_one :structure, through: :commentable

  attr_accessor :show_to_everyone
end
