class TestMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  helper :mailer
  layout 'email'

  default from: "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"
  default to:   "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"

  def mail_action
    mail subject: "Mail action"
  end
end
