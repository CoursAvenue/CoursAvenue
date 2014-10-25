# encoding: utf-8
class PrerenderRenewer

  # Renew cache of url given on Prerender
  # @param url to renew
  def initialize(url)
    if url.is_a? Array
      url.each do |u|
        PrerenderRenewer.renew_url(u)
        sleep 5
      end
      self.check_sanity
    else
      PrerenderRenewer.renew_url(url)
    end
  end

  # Make a post request to Prerender service url to cache it
  def self.renew_url(url)
    puts ENV['PRERENDER_SERVICE_URL'] + url
    uri = URI(ENV['PRERENDER_SERVICE_URL'] + url)
    res = Net::HTTP.post_form(uri, '_escaped_fragment_' => '')
  end

  # Check cached files on S3 by looking there content_length.
  # If they are corupted retry to cache them
  #
  # @return [type] [description]
  def self.check_sanity
    s3 = AWS::S3.new
    corrupted_files = s3.buckets["coursavenue-prerender"].objects.select do |file|
      file.content_length < 50
    end
    corrupted_files = corrupted_files.map do |file|
      file_url = file.public_url.to_s.split('amazonaws.com/').last.gsub('%3A', ':')
      PrerenderRenewer.renew_url file_url
      sleep 5
    end
  end
end
