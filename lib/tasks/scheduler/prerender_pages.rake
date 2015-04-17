namespace :scheduler do

  namespace :prerender do

    # $ rake scheduler:prerender:refresh_vertical_pages
    desc 'Prerender pages and save them to S3.1'
    task :refresh_vertical_pages => :environment do
      include Rails.application.routes.url_helpers
      Rails.application.routes.default_url_options[:host] = 'coursavenue.com'
      Rails.application.routes.default_url_options[:protocol] = Rails.env.production? ? 'https' : 'http'
      VerticalPage.find_each do |vertical_page|
        next if vertical_page.subject.nil?
        if vertical_page.subject and vertical_page.subject.is_root?
          PrerenderRenewer.delay.renew_url(root_vertical_page_url(vertical_page, subdomain: 'www', protocol: 'https', host: 'coursavenue.com'))
          %w(paris marseille lyon toulouse nice nantes bordeaux lille).each do |city_slug|
            PrerenderRenewer.delay.renew_url(root_vertical_page_with_city_url(vertical_page, city_slug, subdomain: 'www', protocol: 'https', host: 'coursavenue.com'))
          end
        else
          PrerenderRenewer.delay.renew_url(vertical_page_url(vertical_page.subject.root, vertical_page, subdomain: 'www', protocol: 'https', host: 'coursavenue.com'))
          %w(paris marseille lyon toulouse nice nantes bordeaux lille).each do |city_slug|
            PrerenderRenewer.delay.renew_url(vertical_page_with_city_url(vertical_page.subject.root, vertical_page, city_slug, subdomain: 'www', protocol: 'https', host: 'coursavenue.com'))
          end
        end
      end
    end

    # To create or update the pre-rendered version of the pages, we send a POST
    # request to the prerender service with the URL to update as a parameter.
    #
    # TODO: Generate the URLs to pre-render.
    # $ rake scheduler:prerender:regenerate_urls
    desc 'Prerender pages and save them to S3'
    task :regenerate_urls => :environment do
      include Rails.application.routes.url_helpers
      Rails.application.routes.default_url_options[:host] = 'coursavenue.com'
      Rails.application.routes.default_url_options[:protocol] = Rails.env.production? ? 'https' : 'http'
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
      if Rails.env.production?
        PrerenderRenewer.delay(queue: 'prerender').new(URLS)
      else
        PrerenderRenewer.new(URLS)
      end
    end
  end
end
