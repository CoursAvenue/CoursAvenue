class Sponsorship < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  USER_WHO_HAVE_BEEN_SPONSORED_CREDIT   = 10 # €
  USER_WHO_SPONSORED_CREDIT             = 3.80 # €

  ######################################################################
  # `attr` macros                                                      #
  ######################################################################

  attr_accessible :sponsored_user, :promo_code

  ######################################################################
  # Relations                                                          #
  ######################################################################
  # The sponsor (sent the invitation).
  belongs_to :user

  # The sponsored user (received the invitation).
  belongs_to :sponsored_user, class_name: 'User'

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

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  scope :succeeded, -> { where(arel_table[:state].eq('bought').or(arel_table[:state].eq('redeemed'))) }
  scope :bought,    -> { where(state: 'bought') }

  # Compute the credit amount that the user that have sponsored people have
  # @param user User who have sponsors
  #
  # @return Double amount of credit to use for next month
  def self.discount_amount_for_sponsorer(user)
    user.sponsorships.bought.count * Sponsorship::USER_WHO_SPONSORED_CREDIT
  end

  # Update the status of the sponsorship.
  #
  # @return self
  def update_state
    if self.state == "bought"
      self.state = "redeemed"
    elsif self.sponsored_user.discovery_pass
      self.state = "bought"
    else
      self.state = "registered"
    end

    self.save
  end

  # How much a user gain to be sponsored
  #
  # @return Integer
  def credit_for_sponsored_user
    USER_WHO_HAVE_BEEN_SPONSORED_CREDIT
  end

  # How much a user gain to be sponsored
  #
  # @return Integer
  def credit_for_sponsorer
    if succeeded
      USER_WHO_SPONSORED_CREDIT
    else
      0
    end
  end

  #
  # Tells wether the sponsorship has been accomplished
  #
  # @return [type] [description]
  def succeeded
    (state == 'bought' or state == 'redeemed')
  end

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
