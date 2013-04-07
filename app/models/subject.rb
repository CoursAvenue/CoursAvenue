class Subject < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_ancestry
  has_attached_file :image, :styles => { super_wide: "850x400#", wide: "600x375#", thumb: "200x200#" }

  has_and_belongs_to_many :courses

  attr_accessible :name, :image, :info

  validates :name, :presence   => true
  validates :name, :uniqueness => true

  def should_generate_new_friendly_id?
    new_record?
  end
end
