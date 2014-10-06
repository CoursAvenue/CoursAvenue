class Sponsorship < ActiveRecord::Base
  ######################################################################
  # Relations                                                          #
  ######################################################################
  # The sponsor (sent the invitation).
  belongs_to :user

  # The invited user (received the invitation).
  has_one :invited_user, class_name: 'User'

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validate :user, presence: true
  validate :invited_user, presence: true
end
