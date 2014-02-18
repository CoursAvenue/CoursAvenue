class Visitor < ActiveRecord::Base
  validates :fingerprint, presence: true, uniqueness: true

  attr_accessible :address_name

end
