class Sponsorship < ActiveRecord::Base

  attr_accessible :sponsored_user, :promo_code

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
  validates :promo_code, presence: true

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_validation :set_promo_code

  private

  # Generates a unique promo code for the sponsorship.
  def set_promo_code
    unless self.promo_code.present?
      code = (0..5).map { ('a'..'z').to_a[rand(26)] }.join

      while Sponsorship.where(promo_code: code).any?
        code = (0..5).map { ('a'..'z').to_a[rand(26)] }.join
      end

      self.promo_code = code
    end
  end
end
