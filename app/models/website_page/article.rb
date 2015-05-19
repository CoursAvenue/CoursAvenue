class WebsitePage::Article < ActiveRecord::Base
  extend FriendlyId
  acts_as_paranoid

  friendly_id :title, use: [:slugged, :finders, :history]

  belongs_to :website_page

  attr_accessible :title, :content, :slug

end
