class EmailingSection < ActiveRecord::Base
  attr_accessible :title

  belongs_to :emailing
  has_many :structures

  validates :title, presence: true
end
