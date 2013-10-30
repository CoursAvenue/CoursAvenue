class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include TruncateHtmlHelper

  attributes :id, :content, :title, :author_name, :course_name, :created_at, :comment_url, :rating

  def content
    # TODO there is a problem with UrlHelper in Rails 4 that breaks this
    # omission = link_to('Lire la suite →', structure_url(object.commentable_id, anchor: "recommandation-#{object.id}"))
    truncate_html(object.content, length: 60, omission: "...").html_safe
  end

  # while link_to and such aren't working, we will just use this
  def comment_url
    "#{object.structure.slug}#recommandation-#{object.id}"
  end

end
