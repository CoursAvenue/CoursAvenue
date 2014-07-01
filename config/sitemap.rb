# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.coursavenue.com"

SitemapGenerator::Sitemap.create do
  def vertical_page_path(subject, city=nil)
    if city
      if subject.depth == 0
        return vertical_root_subject_city_path(subject, city, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
      else
        return vertical_subject_city_path(subject.root, subject, city, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
      end
    else
      if subject.depth == 0
        return vertical_root_subject_path(subject, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
      else
        return vertical_subject_path(subject.root, subject, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
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

  add blog_path, priority: 0.5, changefreq: 'daily'
  add root_path, priority: 0.8, changefreq: 'daily'

  add courses_path, priority: 0.8, changefreq: 'daily'
  add structures_path, priority: 0.8, changefreq: 'daily'

  @paris = City.find 'paris'

  Subject.all.each do |subject|
    add vertical_page_path(subject), priority: 0.8, changefreq: 'weekly'
    add vertical_page_path(subject, @paris), priority: 0.8, changefreq: 'weekly'
  end

  Structure.all.each do |structure|
    add structure_path structure, changefreq: 'daily'
  end
  Course.active.all.each do |course|
    add structure_course_path(course.structure, course), lastmod: course.updated_at, priority: 0.8, changefreq: 'daily'
  end


  [ pages_why_path,
    pages_how_it_works_path,
    pages_faq_users_path,
    pages_faq_partners_path,
    pages_who_are_we_path,
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
