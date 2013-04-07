module CommentsHelper

  # Path of the commentable
  def commentable_path comment
    if comment.commentable.is_a? Structure
      structure_path comment.commentable
    else
      course_path comment.commentable
    end
  end

  def rating_stars rating
    out = ''
    rating = rating.to_i
    5.times do |i|
      if i < rating
        out << content_tag(:i, '', class: 'icon-star yellow')
      else
        out << content_tag(:i, '', class: 'icon-star-empty')
      end
    end
    out.html_safe
  end
end
