class NewsletterMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  # Preview the newsletter.
  def preview(newsletter, to)
    @newsletter = newsletter

    mail to: to,
      subject: @newsletter.object,
      reply_to: @newsletter.reply_to,
      from: "#{@newsletter.sender_name} <noreply@coursavenue.com>"
  end

  def send_newsletter(newsletter)
    @newsletter = newsletter
  end

  # Sends the unsubscription confirmation.
  def confirm_unsubscribtion(newsletter_subscription)
    mail to: newsletter_subscription.email,
      subject: '',
      from:  "#{@newsletter.sender_name} <noreply@coursavenue.com>"
  end
end
