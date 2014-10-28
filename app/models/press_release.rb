class PressRelease < ActiveRecord::Base
  extend FriendlyId
  acts_as_paranoid

  friendly_id :title, use: [:slugged, :finders]

  attr_accessible :title, :description, :content, :published, :published_at

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :published, -> { where( published: true ) }
  default_scope -> { order('published_at DESC') }

end
