class NewsletterMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  # Preview the newsletter.
  def preview(newsletter, to)
    @newsletter = newsletter

    mail to: to,
      subject: "[Aperçu CoursAvenue] #{@newsletter.object}",
      from: "#{@newsletter.sender_name} <noreply@coursavenue.com>"
  end

  # Actually send the newsletter.
  def send_newsletter(newsletter, recipients)
    @newsletter = newsletter

    mail subject: @newsletter.object,
      bcc: recipients,
      from: "#{@newsletter.sender_name} <noreply@coursavenue.com>",
      reply_to: @newsletter.reply_to
  end

  # Sends the unsubscription confirmation.
  def confirm_unsubscribtion(user_profile, newsletter)
    @newsletter = newsletter

    mail to: user_profile.email,
      subject: '',
      from:  "#{@newsletter.sender_name} <noreply@coursavenue.com>"
  end
end
