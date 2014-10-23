namespace :scheduler do

  namespace :prerender do

    # To create or update the pre-rendered version of the pages, we send a POST
    # request to the prerender service with the URL to update as a parameter.
    #
    # TODO: Generate the URLs to pre-render.
    # $ rake scheduler:prerender:regenerate_urls
    desc 'Prerender pages and save them to S3'
    task :regenerate_urls => :environment do
      include Rails.application.routes.url_helpers
      Rails.application.routes.default_url_options[:host] = 'coursavenue.com'
      CITIES = ['paris']
      URLS = []
      CITIES.each do |city|
        URLS << root_search_page_without_subject_url(city, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
      end
      Structure.find_each do |structure|
        URLS << structure_url(structure, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
      end
      Subject.find_each do |subject|
        CITIES.each do |city|
          if subject.is_root?
            URLS << root_search_page_url(subject, city, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
          else
            URLS << search_page_url(subject.root, subject, city, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
          end
        end
      end
      URLS.each do |url|
        if Rails.env.production?
          PrerenderRenewer.delay(queue: 'prerender').new(url)
        else
          PrerenderRenewer.new(url)
        end
      end
    end
  end
end
