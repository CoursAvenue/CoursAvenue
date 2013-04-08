# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.coursavenue.com"

SitemapGenerator::Sitemap.create do
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
  Course.all.each do |course|
    add course_path(course), lastmod: course.updated_at, priority: 0.8

  %w(paris toulouse lyon bordeaux marseille nice montpellier).each do |city|
    Subject.all.each do |subject|
      add city_subject_path(city, subject), changefreq: 0.8
    end
  end

  end

  [ pages_why_path,
    pages_how_it_works_path,
    pages_faq_users_path,
    pages_faq_partners_path,
    pages_who_are_we_path,
    pages_customer_service_path,
    pages_press_path,
    pages_find_a_place_path,
    pages_mentions_partners_path,
    pages_jobs_path,
    pages_contact_path].each do |page_path|
      add page_path, changefreq: 'monthly'
  end

end
