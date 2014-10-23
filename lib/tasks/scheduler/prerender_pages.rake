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
      Rails.application.routes.default_url_options[:host] = (Rails.env.production? ? 'coursavenue.com' : 'staging.coursavenue.com')
      CITIES = ['paris']
      URLS = []
      CITIES.each do |city|
        URLS << root_search_page_without_subject_url(city, subdomain: 'www')
      end
      Structure.find_each do |structure|
        URLS << structure_url(structure, subdomain: 'www')
      end
      Subject.find_each do |subject|
        CITIES.each do |city|
          if subject.is_root?
            URLS << root_search_page_url(subject, city, subdomain: 'www')
          else
            URLS << search_page_url(subject.root, subject, city, subdomain: 'www')
          end
        end
      end
      URLS.each do |url|
        puts ENV['PRERENDER_SERVICE_URL'] + url
        uri = URI(ENV['PRERENDER_SERVICE_URL'] + url)
        res = Net::HTTP.post_form(uri, '_escaped_fragment_' => '')
      end
    end
  end
end
