class Media < ActiveRecord::Base
  acts_as_paranoid

  self.table_name = 'medias'

  attr_accessible :mediable, :mediable_id, :mediable_type, :url, :caption

  before_save :fix_url
  after_save :update_format

  belongs_to :mediable, polymorphic: true
  validates :url, presence: true
  validates :caption, length: { maximum: 255 }

  scope :images,   where(format: "image")
  scope :videos,   where(format: "video")

  auto_html_for :url do
    image
    flickr
    youtube(:width => 400, :height => 250)
    dailymotion(:width => 400, :height => 250)
    vimeo(:width => 400, :height => 250)
  end

  def determine_format
    if url_html.starts_with? '<img'
      'image'
    elsif url_html.starts_with? '<iframe' or url_html.starts_with? '<object'
      'video'
    end
  end

  private

  def update_format
    self.update_column :format, determine_format
  end

  def fix_url
    self.url = URLHelper.fix_url(self.url) if self.url
  end
end
