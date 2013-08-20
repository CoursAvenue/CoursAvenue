class Subject < ActiveRecord::Base
  extend FriendlyId
  # friendly_id :name, use: :slugged
  friendly_id :name, use: [:slugged, :history]

  acts_as_tree

  has_attached_file :image,
                    :styles => { super_wide: "825x250#", wide: "600x375#", thumb: "200x200#" }

  has_and_belongs_to_many :courses
  has_and_belongs_to_many :structures

  attr_accessible :name, :short_name, :image, :info, :parent, :position

  validates :name, presence: true
  validates :name, uniqueness: {scope: 'ancestry'}

  scope :children,       where{ancestry != nil}
  scope :best_roots,     where{(ancestry == nil) & (position != nil)}
  scope :non_best_roots, where{(ancestry == nil) & (position == nil)}
end
