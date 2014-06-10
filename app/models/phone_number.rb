class PhoneNumber < ActiveRecord::Base

  PHONE_TYPES  = ['phone_numbers.type.mobile',
                  'phone_numbers.type.home']

  attr_accessible :number, :phone_type

  belongs_to :callable, polymorphic: true

  validates :number, presence: true
  validates :number, uniqueness: { scope: :callable_id }

end
