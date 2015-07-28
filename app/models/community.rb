class Community < ActiveRecord::Base
  belongs_to :structure

  has_many :threads, -> { order(created_at: :desc) },
    class_name: 'Community::Thread', dependent: :destroy

  has_many :memberships, class_name: 'Community::Membership', dependent: :destroy
  has_many :users, through: :memberships
end
