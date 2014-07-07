# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.coursavenue.com"

SitemapGenerator::Sitemap.create do
  def vertical_page_path(subject)
    if subject.depth == 0
      return vertical_root_subject_path(subject, subdomain: 'www')
    else
      return vertical_subject_path(subject.root, subject, subdomain: 'www')
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

  add blog_path, priority: 0.5, changefreq: 'weekly'
  add root_path, priority: 0.8, changefreq: 'daily'

  add structures_path, priority: 0.8, changefreq: 'daily'

  Structure.all.each do |structure|
    add structure_path structure, changefreq: 'weekly'
  end

  Subject.all.each do |subject|
    add vertical_page_path(subject), priority: 0.8, changefreq: 'weekly'
  end


  [ pages_why_path,
    pages_how_it_works_path,
    pages_faq_users_path,
    pages_faq_partners_path,
    pages_customer_service_path,
    pages_press_path,
    pages_mentions_partners_path,
    pages_jobs_path,
    pages_terms_and_conditions_path,
    pages_contact_path].each do |page_path|
      add page_path, changefreq: 'monthly', priority: 0.1
  end

  # ------------------------------ Pro subdomain
  add root_path(subdomain: :pro), priority: 0.8, changefreq: 'daily'
  add pro_pages_presentation_path(subdomain: :pro), priority: 0.1, changefreq: 'monthly'
  add pro_pages_price_path(subdomain: :pro), priority: 0.1, changefreq: 'monthly'
  add pro_pages_press_path(subdomain: :pro), priority: 0.1, changefreq: 'monthly'

end
