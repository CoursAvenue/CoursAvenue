class Following < ActiveRecord::Base
  belongs_to :user
  belongs_to :structure

  attr_accessible :structure, :user

  validates :structure, :user, presence: true
  validates :user_id, uniqueness: { scope: :structure_id }
end
