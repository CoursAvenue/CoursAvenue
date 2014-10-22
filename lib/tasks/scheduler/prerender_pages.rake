namespace :scheduler do

  # To create or update the pre-rendered version of the pages, we send a POST
  # request to the prerender service with the URL to update as a parameter.
  # TODO: Generate the URLs to pre-render.
  desc 'Prerender pages and save them to S3'
  task :prerender => :environment do
    URLS = []

    URLS.each do |url|
      puts ENV['PRERENDER_SERVICE_URL'] + url
      uri = URI(ENV['PRERENDER_SERVICE_URL'] + url)
      res = Net::HTTP.post_form(uri, '_escaped_fragment_' => '')
    end
  end
end
