class Subscriptions::Sponsorship < ActiveRecord::Base
  include Concerns::HasRandomToken

  acts_as_paranoid

  ######################################################################
  # Macros                                                             #
  ######################################################################

  belongs_to :subscription

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :sponsored_email, uniqueness: true, presence: true

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Consume the sponsorship.
  #
  # @return boolean
  def consume!
    return if consumed?

    self.consumed = true
    save
  end

end
