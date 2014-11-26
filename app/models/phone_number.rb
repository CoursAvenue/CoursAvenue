class PhoneNumber < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  MOBILE_PREFIXES = ['+336', '+337', '00336', '00337', '06', '07']

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :number, :phone_type, :principal

  belongs_to :callable, polymorphic: true, touch: true

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :number,    presence: true
  validates :number,    uniqueness: { scope: :callable_id }

  # This allows us to have a validation based on uniqueness, but only if the
  # boolean field is true.
  validates :principal, uniqueness: { scope: :callable_id }, if: :principal

  ######################################################################
  # Scope                                                              #
  ######################################################################

  default_scope { order('created_at ASC') }

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Check if the number is from a mobile phone.
  #
  # @return Boolean
  def mobile?
    number = MOBILE_PREFIXES.any? { |prefix| self.number.starts_with?(prefix) }
  end
end
