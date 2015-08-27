class CommentReplySerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  cached
  def cache_key
    'CommentReplySerializer/' + object.cache_key + 'v1'
  end

  attributes :id, :content, :simple_format_content

  def simple_format_content
    simple_format(content.strip)
  end

end
