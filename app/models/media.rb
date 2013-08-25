class Media < ActiveRecord::Base
  acts_as_paranoid

  self.table_name = 'medias'

  attr_accessible :mediable, :mediable_id, :mediable_type, :url, :caption

  before_save :fix_url

  belongs_to :mediable, polymorphic: true
  validates :url, presence: true
  validates :caption, length: { maximum: 255 }

  auto_html_for :url do
    image
    flickr
    youtube(:width => 400, :height => 250)
    dailymotion(:width => 400, :height => 250)
    vimeo(:width => 400, :height => 250)
  end

  private

  def fix_url
    self.url = URLHelper.fix_url(self.url) if self.url
  end
end
