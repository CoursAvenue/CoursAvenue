class Audience < ActiveRecord::Base
  has_and_belongs_to_many :course_groups

  attr_accessible :name, :order_number

  validates :name, presence:   true
  validates :name, uniqueness: true
end
