# encoding: utf-8
module CommentsHelper

  def structure_comment_url comment
    structure_url(comment.structure, anchor: "recommandation-#{comment.id}", subdomain: 'www')
  end

  def share_comment_url comment, provider=:facebook
    case provider
    when :facebook
      "http://www.facebook.com/sharer.php?s=100&p[title]=#{comment.title}&p[url]=#{URI.encode(structure_comment_url(comment))}&p[summary]=#{truncate(comment.content, length: 200)}"
    when :twitter
      "https://twitter.com/intent/tweet?text=#{comment.title}&via=CoursAvenue&url=#{URI.encode(structure_comment_url(comment))}"
    end
  end
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

  # Path of the commentable
  def commentable_path comment, options={}
    if comment.commentable.is_a? Structure
      structure_path comment.commentable, options
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
      5.times do |i|
        if rating
          out << content_tag(:i, '', class: 'icon-star yellow')
        else
          out << content_tag(:i, '', class: 'icon-star-empty')
        end
      end
      out.html_safe
    end
  end

  def rating_stars_image rating, options={}
    content_tag :span, class: 'nowrap' do
      out = ''
      5.times do |i|
        if rating
          out << content_tag(:img, '', src: asset_path('icons/icon-star.png'), height: (options[:image_size] || 25), style: "height: #{options[:image_size] || 25}px;")
        else
          out << content_tag(:img, '', src: asset_path('icons/icon-star-empty.png'), height: (options[:image_size] || 25), style: "height: #{options[:image_size] || 25}px;")
        end
      end
      out.html_safe
    end
  end

end
