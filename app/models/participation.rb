class Participation < ActiveRecord::Base

  belongs_to :user
  belongs_to :planning

  attr_accessible :user, :planning

  default_scope -> { order('created_at ASC') }
end
