class SmsLogger < ActiveRecord::Base

  belongs_to :sender, polymorphic: true

  attr_accessible :number, :text, :sender

  # Return the status of the message from Nexmo.
  #
  # @return a hash.
  def status
    return nil if self.nexmo_message_id.nil?

    client = NexmoClientFactory.client
    client.get_message(nexmo_message_id)
  end
end
