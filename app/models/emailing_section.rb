class EmailingSection < ActiveRecord::Base
  attr_accessible :title, :link, :link_name, :structures, :structure_ids

  belongs_to :emailing, polymorphic: true
  has_and_belongs_to_many :structures

  accepts_nested_attributes_for :structures

  validates :title, presence: true
end
