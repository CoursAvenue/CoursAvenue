class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  cached
  def cache_key
    'CommentSerializer/' + object.cache_key
  end

  attributes :id, :content, :title, :author_name, :course_name, :created_at, :rating,
             :created_at_for_human, :comment_url, :avatar_url, :created_at_iso, :certified,
             :simple_format_content, :has_avatar

  has_one :reply, serializer: CommentReplySerializer

  def created_at_for_human
    I18n.l(object.created_at, format: :month_and_year)
  end

  def comment_url
    structure_url((options[:structure] || object.structure), anchor: "recommandation-#{object.id}", subdomain: 'www', host: 'coursavenue.com')
  end

  def has_avatar
    (object.user and object.user.avatar.present?)
  end

  def avatar_url
    if object.user
      object.user.avatar.url(:small_thumb)
    end
  end

  def simple_format_content
    simple_format(content.strip)
  end

  def created_at_iso
    I18n.l(created_at, format: :iso_date_8601)
  end
end
