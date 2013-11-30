class Media::Video < Media
  require 'net/http'
  # pattern is the regex to match the url
  # key is the regex match key to get the id
  FILTER_REGEX = {
    'youtube' => {
      pattern: /https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=player_embedded&v=)([A-Za-z0-9_-]*)(\&\S+)?(\S)*/,
      key: 3,
      video_thumbnail: "http://img.youtube.com/vi/__ID__/0.jpg"
    },
    'dailymotion' => {
      pattern: /http:\/\/www\.dailymotion\.com.*\/video\/(.+)_*/,
      key: 1,
      video_thumbnail: 'http://www.dailymotion.com/thumbnail/video/__ID__'
    },
    'vimeo' => {
      pattern: /https?:\/\/(www.)?vimeo\.com\/([A-Za-z0-9._%-]*)((\?|#)\S+)?/,
      key: 2,
      video_thumbnail: 'http://vimeo.com/api/v2/video/__ID__.json'
    }
  }

  after_save :update_provider
  after_save :update_thumbnail
  before_save :fix_url

  auto_html_for :url do
    youtube(width: 400, height: 250)
    dailymotion(width: 400, height: 250)
    vimeo(width: 400, height: 250)
  end

  private

  def update_thumbnail
    if self.provider_name
      if self.provider_name == 'vimeo'
        url = URI.parse(FILTER_REGEX[self.provider_name][:video_thumbnail].gsub('__ID__', self.provider_id))
        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.request(req)
        }
        thumbnail_url = JSON.parse(res.body).first['thumbnail_large']
      else
        thumbnail_url = FILTER_REGEX[self.provider_name][:video_thumbnail].gsub('__ID__', self.provider_id)
      end
      self.update_column(:thumbnail_url, thumbnail_url)
    end
  end

  def update_provider
    FILTER_REGEX.each do |provider_name, filter_regex|
      match = self.url.match(filter_regex[:pattern])
      if match
        self.update_column :provider_id, match[filter_regex[:key]]
        self.update_column :provider_name, provider_name
      end
    end
  end

  def fix_url
    self.url = URLHelper.fix_url(self.url) if self.url
  end

end
