class EmailingSection < ActiveRecord::Base
  attr_accessible :title, :link, :link_name, :structures, :structure_ids

  belongs_to :emailing, polymorphic: true

  has_many :emailing_section_bridges
  has_many :structures, through: :emailing_section_bridge

  accepts_nested_attributes_for :structures

  validates :title, presence: true
end
