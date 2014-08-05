# encoding: utf-8
class VerticalPage < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :subject
  has_many :medias, as: :mediable

  attr_accessible :name, :caption, :title, :content, :keywords, :subject_id, :image, :medias_attributes,
                  :checked, :comments # For internal use

  accepts_nested_attributes_for :medias,
                                 reject_if: :reject_media,
                                 allow_destroy: true

  has_attached_file :image,
                    :styles => { thumb: '250x200#', large: '1600x500#' }
  validates_attachment_content_type :image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  private

  def reject_media(attributes)
    exists = attributes['id'].present?
    empty = attributes[:url].blank?
    attributes.merge!({:_destroy => 1}) if exists and empty
    return (!exists and empty)
  end


end
