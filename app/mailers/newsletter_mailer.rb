###################################################
#                                                 #
# THIS MAILER IS USED ONLY FOR TESTS, PREVIEWS,   #
# AND GENERATING HTML FOR MANDRILL                #
#                                                 #
###################################################
class NewsletterMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic
  helper NewsletterLayoutHelper

  LAYOUT_WIDTH = 600 # px

  layout 'newsletter'

  # Send the newsletter, also used to preview the newsletter.
  def send_newsletter(newsletter, recipient)
    @newsletter = newsletter
    @structure  = newsletter.structure
    @blocs      = @newsletter.blocs.includes(:sub_blocs).order('position ASC')

    mail subject: (@newsletter.email_object || @newsletter.title),
         to: recipient,
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

  private

  # Override of roadie-rails for having data-mandrill-href turned into href
  def roadie_options
    super.combine(after_transformation: method(:inline_mandrill))
  end

  def inline_mandrill(doc)
    doc.css('[data-mandrill-href]').each do |element|
      element['href'] = element.delete 'data-mandrill-href'
    end
  end

end
