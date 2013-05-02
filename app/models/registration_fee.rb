class RegistrationFee < ActiveRecord::Base
  belongs_to :course

  attr_accessible :for_kid, :amount
end
