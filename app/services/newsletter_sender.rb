class NewsletterSender
  # Send the newsletter to the associated mailing list.
  # @param newsletter The newsletter to send.
  #
  # @return nil
  def self.send_newsletter(newsletter)
    return false if newsletter.mailing_list.nil? or newsletter.sent?

    newsletter.send!
    recipients = newsletter.mailing_list.create_recipients.map(&:email)
    NewsletterMailer.delay.send_newsletter(newsletter, recipients)
    true
  end

  def self.send_preview(newsletter, to)
    NewsletterMailer.delay.preview(newsletter, to)
  end
end
