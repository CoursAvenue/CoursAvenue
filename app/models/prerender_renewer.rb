# encoding: utf-8
class PrerenderRenewer

  SLEEP_LENGTH = 3

  # Renew cache of url given on Prerender
  # @param url to renew
  def initialize(url)
    if url.is_a? Array
      url.each do |u|
        PrerenderRenewer.renew_url(u)
        sleep SLEEP_LENGTH
      end
      PrerenderRenewer.check_sanity
    else
      PrerenderRenewer.renew_url(url)
    end
  end

  # Make a post request to Prerender service url to cache it
  def self.renew_url(url)
    puts ENV['PRERENDER_SERVICE_URL'] + url
    uri = URI(ENV['PRERENDER_SERVICE_URL'] + url)
    res = Net::HTTP.post_form(uri, '_escaped_fragment_' => '')
    # s3 = AWS::S3.new
    # file = s3.buckets["coursavenue-prerender"].objects[file_or_url]
    # file.delete
  end

  # Check cached files on S3 by looking there content_length.
  # If they are corupted retry to cache them
  def self.check_sanity
    s3 = AWS::S3.new
    corrupted_files = s3.buckets["coursavenue-prerender"].objects.select do |file|
      !PrerenderRenewer.is_valid?(file)
    end
    corrupted_files = corrupted_files.map do |file|
      file_url = file.public_url.to_s.split('amazonaws.com/').last.gsub('%3A', ':')
      PrerenderRenewer.renew_url file_url
      sleep SLEEP_LENGTH
    end
  end

  def self.is_valid?(file_or_url)
    if file_or_url.is_a? String
      s3 = AWS::S3.new
      file = s3.buckets["coursavenue-prerender"].objects[file_or_url]
    else
      file = file_or_url
    end
    file.content_length > 50
  end
end
