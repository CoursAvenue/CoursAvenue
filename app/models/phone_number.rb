class PhoneNumber < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  MOBILE_PREFIXES = ['+336', '+337', '00336', '00337', '336', '337', '06', '07', '+33(0)6', '+33(0)7']
  FRANCE_PREFIXES = ['+33', '0033', '33', '0', '+33(0)']

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :number, :phone_type, :info

  belongs_to :callable, polymorphic: true, touch: true

  ######################################################################
  # Validations                                                        #
  ######################################################################

  validates :number,    presence: true
  validates :number,    uniqueness: { scope: :callable_id }

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
    return false if number.nil?
    self.number = self.number.gsub(' ', '')
    MOBILE_PREFIXES.any? { |prefix| number.starts_with?(prefix) }
  end

  def international_format
    new_number = self.number.gsub(' ', '').gsub(/\D/, '').gsub('.', '').gsub('-', '').gsub(/^0/, '')
    "+33 #{new_number}"
  end
end
