class TestMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  helper :mailer
  layout 'email'

  default from: "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"
  default to:   "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"

  def form_test
    @structure = Structure.friendly.find('yoga-sattva-paris')
    @comment   = @structure.comments.build

    mail subject: "form_test"
  end
end
