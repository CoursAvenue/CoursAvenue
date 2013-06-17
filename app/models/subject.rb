class Subject < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  has_ancestry
  has_attached_file :image, :styles => { super_wide: "825x250#", wide: "600x375#", thumb: "200x200#" }

  has_and_belongs_to_many :courses
  has_and_belongs_to_many :structures

  attr_accessible :name, :short_name, :image, :info

  validates :name, presence: true
  validates :name, uniqueness: {scope: 'ancestry'}

  def should_generate_new_friendly_id?
    new_record?
  end
end
