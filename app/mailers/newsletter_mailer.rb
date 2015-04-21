class NewsletterMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic
  helper NewsletterLayoutHelper

  LAYOUT_WIDTH = 600 # px

  layout 'newsletter'

  # Send the newsletter, also used to preview the newsletter.
  def send_newsletter(newsletter, recipients)
    @newsletter = newsletter
    @structure  = newsletter.structure
    @blocs      = @newsletter.blocs.includes(:sub_blocs).order('position ASC')

    mail subject: @newsletter.email_object,
         bcc: recipients,
         from: "\"#{@newsletter.sender_name}\" <noreply@coursavenue.com>",
         reply_to: @newsletter.reply_to
  end

  # Sends the unsubscription confirmation.
  def confirm_unsubscribtion(user_profile, newsletter)
    @newsletter = newsletter
    @structure = newsletter.structure

    mail to: user_profile.email,
         subject: '',
         from:  "\"#{@newsletter.sender_name}\" <noreply@coursavenue.com>"
  end
end
