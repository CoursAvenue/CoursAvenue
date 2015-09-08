# encoding: utf-8
class VerticalPage < ActiveRecord::Base
  extend FriendlyId

  friendly_id :subject_name, use: [:slugged, :finders, :history]

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :subject, touch: true
  has_many :medias, as: :mediable

  attr_accessible :subject_name, :caption, :title, :content, :keywords, :subject_id,
                  :medias_attributes, :sidebar_title, :show_trainings_in_title,
                  :image, :remote_image_url, :page_title, :page_description,
                  :checked, :comments, # For internal use
                  :homepage_position, :depth

  mount_uploader :image, VerticalPageImageUploader

  accepts_nested_attributes_for :medias,
                                 reject_if: :reject_media,
                                 allow_destroy: true

  scope :homepage, -> { order('homepage_position ASC NULLS LAST') }
  scope :roots,    -> { where(depth: 0) }

  # Return reviews related to the vertical page.
  # @param limit=4 Integer number of review wanted
  #
  # @return array of Comment::Review
  def reviews(limit=4, city=nil)
    reviews = []
    if city
      reviews = CommentSearch.search_activerecord(text: subject_name,
                                     per_page: limit,
                                     has_title: true,
                                     lat: city.latitude,
                                     lng: city.longitude,
                                     radius: 10)
    else
      reviews = CommentSearch.search_activerecord(text: subject_name, per_page: limit, has_title: true)
    end
    reviews[0..(limit - 1)]
  end

  def root_subject
    subject.root if subject
  end

  def blog_articles
    BlogArticleSearch.search(name: subject_name, per_page: 3, type: 'user')
  end

  private

  def reject_media(attributes)
    exists = attributes['id'].present?
    empty = attributes[:url].blank?
    attributes.merge!({:_destroy => 1}) if exists and empty
    return (!exists and empty)
  end

end
