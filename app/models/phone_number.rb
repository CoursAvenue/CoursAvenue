class PhoneNumber < ActiveRecord::Base

  MOBILE_PREFIXES = ['+336', '+337', '00336', '00337', '06', '07']

  attr_accessible :number, :phone_type

  belongs_to :callable, polymorphic: true, touch: true

  validates :number, presence: true
  validates :number, uniqueness: { scope: :callable_id }

  # Check if the number is from a mobile phone.
  #
  # @return Boolean
  def mobile?
    number = MOBILE_PREFIXES.any? { |prefix| self.number.starts_with?(prefix) }
  end
end
