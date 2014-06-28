class Blog::Article < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  attr_accessible :title, :description, :content, :published, :subject_ids

  has_and_belongs_to_many :subjects
end
