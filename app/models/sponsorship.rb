class Sponsorship < ActiveRecord::Base
  ######################################################################
  # Relations                                                          #
  ######################################################################
  # The sponsor (sent the invitation).
  belongs_to :user

  # The sponsored user (received the invitation).
  has_one :sponsored_user, class_name: 'User'

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validate :user, presence: true
  validate :sponsored_user, presence: true
end
