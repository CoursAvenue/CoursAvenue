class RegistrationFee < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :course

  attr_accessible :info, :amount
end
