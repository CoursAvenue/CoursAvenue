class Keyword < ActiveRecord::Base
  attr_accessible :name

  validates :name, uniqueness: true

  default_scope -> { order('name ASC') }
end
