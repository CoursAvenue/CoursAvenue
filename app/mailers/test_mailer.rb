class TestMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  default from: "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"
  default to:   "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"

  def form_test
    @structure = Structure.friendly.find('yoga-sattva-paris')
    @comment   = @structure.comments.build

    mail subject: "form_test"
  end

  # Used in the MailerPreview service spec.
  def preview_test(content = 'Random content')
    @content = content
    mail subject: 'preview_test'
  end
end
