class Audience < ActiveRecord::Base
  has_and_belongs_to_many :courses

  attr_accessible :name

  validates :name, presence:   true
  validates :name, uniqueness: true
end
