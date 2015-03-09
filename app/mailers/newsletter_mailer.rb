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
end
