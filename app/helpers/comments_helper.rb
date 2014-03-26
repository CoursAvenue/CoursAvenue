# encoding: utf-8
module CommentsHelper
  def structure_comment_url(comment)
    structure_url(comment.structure, anchor: "recommandation-#{comment.id}", subdomain: 'www')
  end

  def share_comment_url(comment, provider = :facebook)
    case provider
    when :facebook
      URI.encode("http://www.facebook.com/sharer.php?s=100&p[title]=\"#{comment.title}\" par #{comment.author_name}&p[url]=#{structure_comment_url(comment)}&p[summary]=#{truncate(comment.content, length: 200)}")
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
      structure_url(comment.commentable, { subdomain: 'www' }.merge(options))
    elsif comment.commentable
      structure_course_url comment.commentable.structure, comment.commentable, { subdomain: 'www' }.merge(options)
    end
  end
end
