class CommentReplySerializer < ActiveModel::Serializer

  cached
  def cache_key
    'CommentReplySerializer/' + object.cache_key
  end

  attributes :id, :content

end
