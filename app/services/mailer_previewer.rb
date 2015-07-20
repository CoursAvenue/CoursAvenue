class MailerPreviewer
  # Create a preview of an email and return it as a string so it can be passed in a view.
  # Usage:
  #    mail = UserMailer.welcome(@user)
  #    @content = MailerPreviewer.preview(mail)
  #    # Render it in your view:
  #
  #    = @content.html_safe
  #
  # @param mail The Mail object to preview.
  #
  # @return The Mail content as a String.
  def self.preview(mail_object)
    inliner = Roadie::Rails::MailInliner.new(mail_object, Rails.application.config.roadie)
    mail = inliner.execute

    mail.html_part.decoded
  end
end
