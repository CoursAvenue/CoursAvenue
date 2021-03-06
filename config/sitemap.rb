# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.coursavenue.com"

SitemapGenerator::Sitemap.create do

  Place.all.map(&:city).uniq.each do |city|
    Subject.find_each do |subject|
      if subject.depth == 0
        add root_search_page_path(subject, city)
      else
        add search_page_path(subject.root, subject, city)
      end
    end
  end
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  # add root_path, priority: 0.8, changefreq: 'daily'

  # add blog_articles_path, priority: 0.5, changefreq: 'weekly'

  # Blog::Article.find_each do |article|
  #   add blog_article_path(article), priority: 0.5
  # end

  # Subject.roots.stars.find_each do |root_subject|
  #   %w(paris marseille lyon toulouse nice nantes bordeaux lille).each do |city_slug|
  #     add root_search_page_path(root_subject, city_slug), priority: 0.9, changefreq: 'weekly'
  #   end
  # end
  # Subject.find_each do |subject|
  #   next if subject.is_root?
  #   %w(paris marseille lyon toulouse nice nantes bordeaux lille).each do |city_slug|
  #     add search_page_path(subject.root, subject, city_slug), priority: 0.9, changefreq: 'weekly'
  #   end
  # end

  # Structure.all.each do |structure|
  #   add structure_path structure, changefreq: 'weekly'
  # end

  # VerticalPage.find_each do |vertical_page|
  #   next if vertical_page.subject.nil?
  #   if vertical_page.subject and vertical_page.subject.is_root?
  #     add root_vertical_page_path(vertical_page), priority: 0.5, changefreq: 'weekly'
  #     %w(paris marseille lyon toulouse nice nantes bordeaux lille).each do |city_slug|
  #       add root_vertical_page_with_city_path(vertical_page, city_slug), priority: 0.5, changefreq: 'weekly'
  #     end
  #   else
  #     add vertical_page_path(vertical_page.subject.root, vertical_page), priority: 0.5, changefreq: 'weekly'
  #     %w(paris marseille lyon toulouse nice nantes bordeaux lille).each do |city_slug|
  #       add vertical_page_with_city_path(vertical_page.subject.root, vertical_page, city_slug), priority: 0.5, changefreq: 'weekly'
  #     end
  #   end
  # end

end

# Renew vertical pages cache
# include Rails.application.routes.url_helpers
# VerticalPage.find_each do |vertical_page|
#   next if vertical_page.subject.nil?
#   if vertical_page.subject and vertical_page.subject.is_root?
#     PrerenderRenewer.delay.renew_url(root_vertical_page_url(vertical_page, subdomain: 'www', protocol: 'https', host: 'coursavenue.com'))
#     %w(paris marseille lyon toulouse nice nantes bordeaux lille).each do |city_slug|
#       PrerenderRenewer.delay.renew_url(root_vertical_page_with_city_url(vertical_page, city_slug, subdomain: 'www', protocol: 'https', host: 'coursavenue.com'))
#     end
#   else
#     PrerenderRenewer.delay.renew_url(vertical_page_url(vertical_page.subject.root, vertical_page, subdomain: 'www', protocol: 'https', host: 'coursavenue.com'))
#     %w(paris marseille lyon toulouse nice nantes bordeaux lille).each do |city_slug|
#       PrerenderRenewer.delay.renew_url(vertical_page_with_city_url(vertical_page.subject.root, vertical_page, city_slug, subdomain: 'www', protocol: 'https', host: 'coursavenue.com'))
#     end
#   end
# end
