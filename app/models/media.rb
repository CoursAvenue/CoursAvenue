class Media < ActiveRecord::Base
  self.table_name = 'medias'

  attr_accessible :mediable, :mediable_id, :mediable_type, :url, :caption

  belongs_to :mediable, polymorphic: true
  validates :caption, length: { maximum: 255 }

  auto_html_for :url do
    image
    flickr
    youtube(:width => 400, :height => 250)
    dailymotion(:width => 400, :height => 250)
    vimeo(:width => 400, :height => 250)
  end
end
