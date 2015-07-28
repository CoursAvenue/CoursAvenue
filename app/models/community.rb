class Community < ActiveRecord::Base
  belongs_to :structure

  has_many :message_threads, -> { order(created_at: :desc) },
    class_name: 'Community::MessageThread', dependent: :destroy

  has_many :memberships, class_name: 'Community::Membership', dependent: :destroy
  has_many :users, through: :memberships
end
