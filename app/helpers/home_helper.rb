require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

module HomeHelper
  def blog_feed
    source = "http://54.217.250.8/feed" # url or local file
    content = "" # raw content of rss feed will be loaded here
    begin
      open(source) do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)

    html = "<ul class='blog-feed flush--bottom'>"
    rss.items[0..3].each do |rss_item|
      html << "<li class='white-box islet' itemscope itemtype='http://schema.org/Article'>"
      html << content_tag(:h4, link_to(rss_item.title, rss_item.link, target: '_blank'), class: 'blog-feed__title flush--bottom', itemprop: 'name')
      html << content_tag(:span, l(rss_item.pubDate, format: :date).capitalize, class: 'blog-feed__date', itemprop: 'dateCreated')
      html << content_tag(:p, rss_item.description.split('The post')[0].html_safe, class: 'blog-feed__content flush--bottom', itemprop: 'text')
      html << "</li>"
    end
    html << "</ul>"
    html.html_safe
    rescue Exception => e
    end
  end
end
