class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include TruncateHtmlHelper

  attributes :id, :content, :title, :author_name, :course_name, :created_at

  def content
    # TODO there is a problem with UrlHelper in Rails 4 that breaks this
    # omission = link_to('Lire la suite →', structure_url(object.commentable_id, anchor: "recommantation-#{object.id}"))
    truncate_html(object.content, length: 100, omission: "...").html_safe
  end

end
