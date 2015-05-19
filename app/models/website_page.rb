class WebsitePage < ActiveRecord::Base
  extend FriendlyId
  acts_as_paranoid

  friendly_id :title, use: [:slugged, :finders, :history]

  belongs_to :structure

  has_many :articles, class_name: 'WebsitePage::Article'

  attr_accessible :title, :articles_attributes, :slug

  accepts_nested_attributes_for :articles

end
