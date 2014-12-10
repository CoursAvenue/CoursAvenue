class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :content, :title, :author_name, :course_name, :created_at, :rating,
             :distance_of_time, :comment_url, :avatar_url, :created_at_iso, :certified

  has_one :reply, serializer: CommentReplySerializer

  def distance_of_time
    distance_of_time_in_words_to_now self.created_at
  end

  def comment_url
    structure_url((options[:structure] || object.structure), anchor: "recommandation-#{object.id}", subdomain: CoursAvenue::Application::WWW_SUBDOMAIN, host: 'coursavenue.com')
  end

  def avatar_url
    if object.user
      object.user.avatar_url(:small_thumb)
    end
  end

  def created_at_iso
    I18n.l(created_at, format: :iso_date_8601)
  end
end
