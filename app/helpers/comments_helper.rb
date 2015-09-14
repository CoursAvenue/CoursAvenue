# encoding: utf-8
module CommentsHelper
  def structure_comment_url(comment)
    structure_url(comment.structure, subdomain: 'www')
  end

  def share_comment_url(comment, provider = :facebook)
    case provider
    when :facebook
      # Add c parameter to pass id of the comment in the URL and have specific og:title and description
      URI.encode("http://www.facebook.com/sharer.php?s=100&p[url]=#{structure_url(comment.structure, c: comment.id, subdomain: 'www')}")
    when :twitter
      URI.encode("https://twitter.com/intent/tweet?text=\"#{comment.title}\" par #{comment.author_name}&via=CoursAvenue&url=#{structure_comment_url(comment)}")
    end
  end

  # Path of the commentable
  def commentable_path(comment, options = {})
    if comment.commentable.is_a? Structure
      structure_path comment.commentable, options
    elsif comment.commentable
      structure_course_path comment.commentable.structure, comment.commentable, options
    end
  end

  # URL of the commentable
  def commentable_url(comment, options = {})
    if comment.commentable.is_a? Structure
      structure_url(comment.commentable, { subdomain: 'www', anchor: "recommandation-#{comment.id}" }.merge(options))
    elsif comment.commentable
      structure_course_url comment.commentable.structure, comment.commentable, { subdomain: 'www' }.merge(options)
    end
  end

  def icon_rating(comment, class_name='')
    if comment.rating.nil? or comment.rating > 3
      content_tag(:i, '', class: "fa-face-happy #{class_name}")
    elsif comment.rating > 1
      content_tag(:i, '', class: "fa-face-neutral #{class_name}")
    else
      content_tag(:i, '', class: "fa-face-sad #{class_name}")
    end
  end
end
