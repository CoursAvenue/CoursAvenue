class SmsLogger < ActiveRecord::Base

  belongs_to :sender, polymorphic: true

  attr_accessible :number, :text, :sender

end
