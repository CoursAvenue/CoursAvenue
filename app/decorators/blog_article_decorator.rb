class BlogArticleDecorator < Draper::Decorator

  def page_title
    if object.page_title.present? and object.page_title.length < 47
      if object.pro_article?
        "#{object.page_title} | CoursAvenuePro"
      else
        "#{object.page_title} | CoursAvenue.com"
      end
    elsif object.page_title.present?
      object.page_title
    else
      object.title
    end
  end

  def share_url(provider=:facebook)
    case provider
    when :facebook
      URI.encode("http://www.facebook.com/sharer.php?s=100&p[title]=#{object.title}&p[url]=#{h.blog_article_url(object, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)}&p[summary]=#{object.description}")
    when :twitter
      URI.encode("https://twitter.com/intent/tweet?text=#{object.title}&via=CoursAvenue&url=#{h.blog_article_url(object, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)}")
    end
  end
end
