# encoding: utf-8
class VerticalPage < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :subject
  has_many :medias, as: :mediable

  attr_accessible :name, :caption, :title, :content, :keywords, :subject_id, :image, :medias_attributes, :sidebar_title,
                  :checked, :comments # For internal use

  accepts_nested_attributes_for :medias,
                                 reject_if: :reject_media,
                                 allow_destroy: true

  has_attached_file :image,
                    styles: { thumb: '250x200#', large: '1600x500#' },
                    convert_options: { thumb: '-interlace Plane', large: '-interlace Plane' }

  validates_attachment_content_type :image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']


  # Return reviews related to the vertical page.
  # @param limit=4 Integer number of review wanted
  #
  # @return array of Comment::Review
  def reviews(limit=4)
    reviews = []
    slugs = [subject.slug] + subject.ancestors.map(&:slug).reverse
    slugs.each do |slug|
      reviews += CommentSearch.search(per_page: limit, has_title: true, subject_slug: slug).results

      break if reviews.length >= limit
    end
    reviews[0..(limit - 1)]
  end

  private

  def reject_media(attributes)
    exists = attributes['id'].present?
    empty = attributes[:url].blank?
    attributes.merge!({:_destroy => 1}) if exists and empty
    return (!exists and empty)
  end

end
