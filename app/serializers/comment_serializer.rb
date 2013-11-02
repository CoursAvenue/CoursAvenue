class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper
  include TruncateHtmlHelper

  attributes :id, :content, :title, :author_name, :course_name, :content_html, :created_at, :distance_of_time

  def content_html
    # omission = link_to('Lire la suite →', structure_url(object.commentable_id, anchor: "recommantation-#{object.id}"))
    truncate_html(simple_format(object.content), length: 600).html_safe
  end

  def distance_of_time
    distance_of_time_in_words_to_now self.created_at
  end
end
