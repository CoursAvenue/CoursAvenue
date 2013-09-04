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
    if comment.title.present?
      comment.title.capitalize
    elsif comment.commentable.is_a? Structure
      comment.commentable.name
    elsif comment.commentable
      comment.commentable.name
    end
  end

  # Path of the commentable
  def commentable_path comment, options={}
    if comment.commentable.is_a? Structure
      structure_path comment.commentable
    elsif comment.commentable
      structure_course_path comment.commentable.structure, comment.commentable, options
    end
  end

  # URL of the commentable
  def commentable_url comment, options={}
    if comment.commentable.is_a? Structure
      structure_url(comment.commentable, {subdomain: 'www'}.merge(options))
    elsif comment.commentable
      structure_course_url comment.commentable.structure, comment.commentable, {subdomain: 'www'}.merge(options)
    end
  end

  def rating_stars rating
    content_tag :span, class: 'nowrap' do
      out = ''
      rating       = rating.to_f
      5.times do |i|
        delta = rating - i
        if delta > 0.9
          out << content_tag(:i, '', class: 'icon-star yellow')
        elsif delta > 0.7
          out << content_tag(:i, '', class: 'icon-star yellow')
        elsif delta > 0.2
          out << content_tag(:i, '', class: 'icon-star-half-empty yellow')
        else
          out << content_tag(:i, '', class: 'icon-star-empty')
        end
      end
      out.html_safe
    end
  end

end
