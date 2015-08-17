class CommentReplySerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  attributes :id, :content

end
