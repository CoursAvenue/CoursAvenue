class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::UrlHelper
  include TruncateHtmlHelper

  attributes :id, :content, :title, :author_name, :course_name, :created_at, :comment_url, :rating, :comments_url, :distance_of_time

  def content
    truncate_html(object.content, length: 100, omission: "...").html_safe
  end

  # while link_to and such aren't working, we will just use this
  def comment_url
    # TODO there is a problem with UrlHelper in Rails 4 that breaks this
    "etablissements/#{object.structure.slug}#recommandation-#{object.id}"
  end

  def comments_url
    "etablissements/#{object.structure.slug}"
  end

  def distance_of_time
    distance_of_time_in_words_to_now self.created_at
  end
end
