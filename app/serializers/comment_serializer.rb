class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper
  include TruncateHtmlHelper

  attributes :id, :content, :title, :author_name, :course_name, :created_at, :rating, :distance_of_time, :full_content

  def content
    truncate_html(object.content, length: 100, omission: "...").html_safe
  end

  def full_content
    object.content
  end

  def distance_of_time
    distance_of_time_in_words_to_now self.created_at
  end
end
