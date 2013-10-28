class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include TruncateHtmlHelper

  attributes :id, :content, :title, :author_name, :course_name, :content_html, :created_at

  def content_html
    # omission = link_to('Lire la suite →', structure_url(object.commentable_id, anchor: "recommantation-#{object.id}"))
    truncate_html(simple_format(object.content), length: 600).html_safe
  end

end
