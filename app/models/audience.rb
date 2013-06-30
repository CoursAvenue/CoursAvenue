# class Audience < ActiveHash::Base
#   include ActiveHash::Enum

#   self.data = [
#     { id: 1, short_name: 'Kid' ,    name: 'audience.kid',    order: 1 },
#     { id: 2, short_name: 'Adult' ,  name: 'audience.adult',  order: 2 },
#     { id: 3, short_name: 'Senior' , name: 'audience.senior', order: 3 }
#   ]
#   enum_accessor :short_name
# end

class Audience < ActiveRecord::Base

  has_many :courses, through: :plannings
  has_and_belongs_to_many :plannings

  attr_accessible :name, :order

  validates :name, presence:   true
  validates :name, uniqueness: true

  def self.kid
    Audience.where(name: 'audience.kid').first
  end

  def self.adult
    Audience.where(name: 'audience.adult').first
  end

  def self.senior
    Audience.where(name: 'audience.senior').first
  end
end
