class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  attributes :id, :content, :title, :author_name, :course_name, :created_at, :rating,
             :distance_of_time, :comment_url, :avatar_url

  has_one :reply, serializer: CommentReplySerializer

  def distance_of_time
    distance_of_time_in_words_to_now self.created_at
  end

  def comment_url
    structure_url((options[:structure] || object.structure), anchor: "recommandation-#{object.id}", subdomain: CoursAvenue::Application::WWW_SUBDOMAIN, host: 'coursavenue.com')
  end

  def avatar_url
    object.user.avatar_url
  end
end
