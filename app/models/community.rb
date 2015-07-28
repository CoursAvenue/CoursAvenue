class Community < ActiveRecord::Base
  belongs_to :structure

  has_many :memberships, class_name: 'Community::Membership', dependent: :destroy
  has_many :users, through: :memberships
end
