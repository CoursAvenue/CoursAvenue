class NewsletterSender
  # Send the newsletter to the associated mailing list.
  # @param newsletter The newsletter to send.
  #
  # @return nil
  def self.send_newsletter(newsletter)
    return false if newsletter.mailing_list.nil? or newsletter.sent?

    newsletter.send!
    NewsletterMailer.delay.send_newsletter(newsletter)
    true
  end
end
