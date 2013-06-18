class Media < ActiveRecord::Base
  set_table_name 'medias' # Fails sinon

  attr_accessible :mediable, :mediable_id, :mediable_type, :url, :caption

  belongs_to :mediable, polymorphic: true

  auto_html_for :url do
    image
    flickr
    youtube(:width => 400, :height => 250)
    dailymotion(:width => 400, :height => 250)
    vimeo(:width => 400, :height => 250)
  end
end
