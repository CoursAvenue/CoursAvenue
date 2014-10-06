class Sponsorship < ActiveRecord::Base

  attr_accessible :sponsored_user

  ######################################################################
  # Relations                                                          #
  ######################################################################
  # The sponsor (sent the invitation).
  belongs_to :user

  # The sponsored user (received the invitation).
  has_one :sponsored_user, class_name: 'User', foreign_key: 'sponsorship_id'

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :user, presence: true
  validates :sponsored_user, presence: true
end
