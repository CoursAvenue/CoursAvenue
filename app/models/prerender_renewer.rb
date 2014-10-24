# encoding: utf-8
class PrerenderRenewer

  # Renew cache of url given on Prerender
  # @param url to renew
  def initialize(url)
    if url.is_a? Array
      url.each do |u|
        renew_url(u)
        sleep 5
      end
      self.check_sanity
    else
      renew_url(url)
    end
  end

  # Make a post request to Prerender service url to cache it
  def renew_url(url)
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
    corrupted_files.map do |file|
      PrerenderRenewer.new file.public_url.to_s.split('amazonaws.com/').last.gsub('%3A', ':')
      sleep 5
    end
  end
end
