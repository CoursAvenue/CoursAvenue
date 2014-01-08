class Participation < ActiveRecord::Base

  belongs_to :user
  belongs_to :planning

  default_scope -> { order('created_at ASC') }
end
