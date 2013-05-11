# encoding: utf-8
module CommentsHelper

  def comment_rating_title rating
    rating = rating.to_i
    case rating
    when 0
      'Note : 0 étoile (Épouvantable)'
    when 1
      'Note : 1 étoile (Épouvantable)'
    when 2
      'Note : 2 étoiles (Mauvais)'
    when 3
      'Note : 3 étoiles (Moyen)'
    when 4
      'Note : 4 étoiles (Très bon)'
    when 5
      'Note : 5 étoiles (Excellent !)'
    end
  end

  # Name of the commentable
  def commentable_name comment
    if comment.commentable.is_a? Place
      comment.commentable.long_name
    elsif comment.commentable
      comment.commentable.name
    end
  end

  # Path of the commentable
  def commentable_path comment, options={}
    if comment.commentable.is_a? Place
      place_path comment.commentable, options
    elsif comment.commentable
      course_path comment.commentable, options
    end
  end

  # URL of the commentable
  def commentable_url comment, options={}
    if comment.commentable.is_a? Place
      place_url comment.commentable, options
    elsif comment.commentable
      course_url comment.commentable, options
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
