class Newsletter::Metric < ActiveRecord::Base
  belongs_to :newsletter
  attr_accessible :newsletter

  MANDRILL_SENT_STATE     = 'sent'
  MANDRILL_BOUNCED_STATE  = 'bounced'
  MANDRILL_REJECTED_STATE = 'rejected'

  # Updates the metric in a delay job unless an update is already delayed.
  #
  # @return nothing
  def delayed_update
    self.delay.update_metrics!
  end

  private

  # Update the metrics by calling the Mandrill api.
  #
  # @return nothing
  def update_metrics!
    recipients = newsletter.recipients
    recipients.each(&:update_message_status)

    self.nb_opening    = recipients.select(&:opened).count
    self.nb_click      = recipients.map(&:clicks).reduce(:+)
    self.nb_bounced    = recipients.where(mandrill_message_status: MANDRILL_BOUNCED_STATE).count
    self.nb_email_sent = recipients.where(mandrill_message_status: MANDRILL_SENT_STATE).count

    save
  end
end
