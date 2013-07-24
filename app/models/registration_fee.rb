class RegistrationFee < ActiveRecord::Base
  belongs_to :course

  attr_accessible :info, :amount
end
