require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

module HomeHelper
  def blog_feed
    source = "http://blog.leboncours.com/feed/" # url or local file
    content = "" # raw content of rss feed will be loaded here
    open(source) do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)

    html = "<ul class='blog-feed'>"
    rss.items[0..3].each do |rss_item|
      html << "<li>"
      html << content_tag(:h4, link_to(rss_item.title, rss_item.link), class: 'blog-feed__title flush--bottom')
      html << content_tag(:span, l(rss_item.pubDate, format: :date).capitalize, class: 'blog-feed__date')
      html << content_tag(:p, rss_item.description.html_safe, class: 'blog-feed__content')
      html << "</li>"
    end
    html << "</ul>"
    html.html_safe
  end
end
