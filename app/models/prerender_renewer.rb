# encoding: utf-8
class PrerenderRenewer

  # Renew cache of url given on Prerender
  # @param url to renew
  def initialize(url)
    if url.is_a? Array
      url.each do |u|
        renew_url(u)
        sleep 1
      end
    else
      renew_url(url)
    end
  end

  def renew_url(url)
    puts ENV['PRERENDER_SERVICE_URL'] + url
    uri = URI(ENV['PRERENDER_SERVICE_URL'] + url)
    res = Net::HTTP.post_form(uri, '_escaped_fragment_' => '')
  end

end
