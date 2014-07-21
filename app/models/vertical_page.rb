# encoding: utf-8
class VerticalPage < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  belongs_to :subject

  attr_accessible :name, :caption, :title, :content, :keywords, :subject_id, :image

  has_attached_file :image,
                    :styles => { thumb: '250x200#' }
  validates_attachment_content_type :image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

end
