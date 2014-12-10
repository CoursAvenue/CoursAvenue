class PhoneNumber < ActiveRecord::Base

  attr_accessible :number, :phone_type

  belongs_to :callable, polymorphic: true, touch: true

  validates :number, presence: true
  validates :number, uniqueness: { scope: :callable_id }

end
