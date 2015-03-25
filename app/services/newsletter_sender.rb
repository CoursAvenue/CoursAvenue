# Service for sending Pro Newsletters.
# Uses mandrill instead of the regular mailers.
class NewsletterSender
  # Send the newsletter to the associated mailing list.
  # @param newsletter The newsletter to send.
  #
  # @return nil
  def self.send_newsletter(newsletter)
    return false if newsletter.mailing_list.nil? or newsletter.sent?

    client  = MandrillFactory.client
    message = newsletter.to_mandrill_message
    async   = false
    ip_pool = 'Main Pool'

    sending_informations = client.messages.send message, async, ip_pool

    if sending_informations
      newsletter.send!(sending_informations)
    end

    sending_informations
  end

  # Send the newsletter to the passed recipients.
  #
  # @return nothing.
  def self.send_preview(newsletter, to)
    NewsletterMailer.delay.preview(newsletter, to)
  end
end
