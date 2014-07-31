class Portrait < ActiveRecord::Base
  extend FriendlyId

  friendly_id :thumb_title, use: [:slugged, :finders]

  has_many :medias, as: :mediable

  attr_accessible :thumb_title, :thumb_subtitle, :title, :quote_name, :quote, :top_line, :content, :bottom_line, :visible, :top_line_about

end
