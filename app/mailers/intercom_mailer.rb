class IntercomMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  default from: 'CoursAvenue <hello@coursavenue.com>'
  default to:   'kryqhl33@incoming.intercom.io'

  def notify_no_public_reply(thread)
    @thread  = thread
    @message = thread.messages.first.body
    @structure = thread.community.structure

    mail subject: "Nouveau message publique pour l'établissement #{ @structure.name }"
  end
end
